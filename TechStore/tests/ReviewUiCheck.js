/* Optional fixture-only Chrome CDP checks, invoked by ReviewIntegrationTest --ui.
 * Requires an isolated headless Chrome on 127.0.0.1:9224. No screenshots or external packages.
 */
'use strict';
const assert = require('node:assert/strict');
const base = process.env.REVIEW_TEST_BASE;
const prefix = process.env.REVIEW_TEST_PREFIX;
const password = process.env.REVIEW_TEST_PASSWORD;
const product = Number(process.env.REVIEW_TEST_PRODUCT);
const emptyProduct = Number(process.env.REVIEW_TEST_EMPTY_PRODUCT);
if (!base || !prefix || !password || !product || !emptyProduct) throw Error('Run only through local ReviewIntegrationTest --ui fixtures.');
const pause = ms => new Promise(resolve => setTimeout(resolve, ms));
let assertions = 0;
function check(value, message) { assert.ok(value, message); assertions++; console.log('BROWSER PASS ' + message); }

class CDP {
    static async connect(url) {
        const connection = new CDP();
        connection.socket = new WebSocket(url);
        connection.nextId = 0; connection.pending = new Map(); connection.listeners = new Map();
        connection.socket.addEventListener('message', event => {
            const data = JSON.parse(event.data);
            if (data.id) {
                const pending = connection.pending.get(data.id);
                if (!pending) return;
                clearTimeout(pending.timeout); connection.pending.delete(data.id);
                if (data.error) pending.reject(Error(data.error.message)); else pending.resolve(data.result);
            } else (connection.listeners.get(data.method) || []).forEach(listener => listener(data.params));
        });
        await new Promise((resolve, reject) => { connection.socket.addEventListener('open', resolve, {once:true}); connection.socket.addEventListener('error', reject, {once:true}); });
        return connection;
    }
    send(method, params = {}) {
        const id = ++this.nextId;
        return new Promise((resolve, reject) => {
            const timeout = setTimeout(() => { this.pending.delete(id); reject(Error('CDP timeout: ' + method)); }, 15000);
            this.pending.set(id, {resolve,reject,timeout});
            this.socket.send(JSON.stringify({id,method,params}));
        });
    }
    on(method, listener) { const list = this.listeners.get(method) || []; list.push(listener); this.listeners.set(method,list); }
    async evaluate(expression) {
        const data = await this.send('Runtime.evaluate',{expression,returnByValue:true,awaitPromise:true});
        if (data.exceptionDetails) throw Error(data.exceptionDetails.exception?.description || data.exceptionDetails.text);
        return data.result.value;
    }
    async waitFor(expression, description = expression) {
        for (let i=0;i<80;i++) { if (await this.evaluate(expression)) return; await pause(100); }
        throw Error('Browser condition timed out: ' + description);
    }
    async navigate(path) {
        await this.send('Page.navigate',{url:base+path});
        await this.waitFor('document.readyState === "complete" && !!document.querySelector("[data-review-section]")','loaded review page');
    }
    async viewport(width) { await this.send('Emulation.setDeviceMetricsOverride',{width,height:1000,deviceScaleFactor:1,mobile:width<768}); await pause(80); }
    async click(selector) {
        const position = await this.evaluate(`(() => { const e=document.querySelector(${JSON.stringify(selector)}); e.scrollIntoView({block:'center'}); const r=e.getBoundingClientRect(); return {x:r.x+r.width/2,y:r.y+r.height/2}; })()`);
        await this.send('Input.dispatchMouseEvent',{type:'mouseMoved',...position});
        await this.send('Input.dispatchMouseEvent',{type:'mousePressed',button:'left',clickCount:1,...position});
        await this.send('Input.dispatchMouseEvent',{type:'mouseReleased',button:'left',clickCount:1,...position});
    }
    async key(key, code, virtualKey) {
        await this.send('Input.dispatchKeyEvent',{type:'keyDown',key,code,windowsVirtualKeyCode:virtualKey});
        await this.send('Input.dispatchKeyEvent',{type:'keyUp',key,code,windowsVirtualKeyCode:virtualKey});
    }
    close() { this.socket.close(); }
}

(async () => {
    const version = await (await fetch('http://127.0.0.1:9224/json/version')).json();
    const browser = await CDP.connect(version.webSocketDebuggerUrl);
    const contexts = [], connections = [], errors = [];
    async function page() {
        const context = await browser.send('Target.createBrowserContext'); contexts.push(context.browserContextId);
        const target = await browser.send('Target.createTarget',{url:'about:blank',browserContextId:context.browserContextId});
        const targets = await (await fetch('http://127.0.0.1:9224/json/list')).json();
        const connection = await CDP.connect(targets.find(item => item.id===target.targetId).webSocketDebuggerUrl);
        connections.push(connection);
        connection.on('Runtime.exceptionThrown', event => errors.push(event.exceptionDetails.text));
        await connection.send('Runtime.enable'); await connection.send('Page.enable'); await connection.send('Network.enable');
        // Keep the browser checks entirely local; related-product images never contact external hosts.
        await connection.send('Fetch.enable',{patterns:[{urlPattern:'*',requestStage:'Request'}]});
        connection.on('Fetch.requestPaused', event => {
            const url = new URL(event.request.url);
            const local = ['localhost','127.0.0.1'].includes(url.hostname) || ['data:','about:'].includes(url.protocol);
            connection.send(local?'Fetch.continueRequest':'Fetch.failRequest', local?{requestId:event.requestId}:{requestId:event.requestId,errorReason:'BlockedByClient'}).catch(error=>errors.push(error.message));
        });
        return connection;
    }
    async function login(connection, role) {
        await connection.navigate('/product-detail?id='+product);
        const status = await connection.evaluate(`fetch(${JSON.stringify(base+'/login')},{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:new URLSearchParams(${JSON.stringify({username:prefix+role,password})}).toString()}).then(r=>r.status)`);
        check(status===200,'fixture login in isolated browser context');
        // fetch authenticates cookies but does not replace the guest DOM; refresh before a hash-only deep link.
        await connection.send('Page.reload');
        await connection.waitFor(`document.readyState==='complete' && document.querySelector('.ts-profile-menu-header strong')?.textContent.trim()===${JSON.stringify(prefix+role)}`,'authenticated page after login');
    }
    try {
        const guest = await page(); await guest.viewport(1440);
        await guest.navigate('/product-detail?id='+emptyProduct);
        check(await guest.evaluate('!document.querySelector(".ts-review-overview") && !!document.querySelector(".ts-review-empty-art") && getComputedStyle(document.querySelector(".ts-reviews-layout")).gridTemplateColumns.split(" ").length===1'),'empty state has one balanced column and no fake overview');
        check(await guest.evaluate('!document.querySelector("[data-review-form]") && document.querySelector(".ts-review-compose").textContent.includes("Đăng nhập")'),'guest gets login card, never a submitting review form');
        await guest.navigate('/product-detail?id='+product);
        const overview = await guest.evaluate(`(() => { const rows=[...document.querySelectorAll('[data-review-level]')]; const ratings=[...document.querySelectorAll('.ts-review-stars')].map(e=>Number(e.getAttribute('aria-label').split(' ')[0])); const mean=ratings.reduce((a,b)=>a+b,0)/ratings.length; return {count:ratings.length,sum:rows.reduce((n,e)=>n+Number(e.dataset.reviewCount),0),mean,shown:parseFloat(document.querySelector('.ts-review-score strong').textContent.replace(',','.')),fill:document.querySelector('.ts-review-average-fill').getBoundingClientRect().width/document.querySelector('.ts-review-average-stars').getBoundingClientRect().width,avatars:document.querySelectorAll('.ts-review-avatar').length}; })()`);
        check(overview.count===overview.sum && Math.abs(overview.mean-overview.shown)<.051,'distribution, average and loaded comment count agree');
        check(Math.abs(overview.fill-overview.mean/5)<.015,'gold average stars are clipped to the real score');
        check(overview.avatars===overview.count,'every actual review has an initials avatar');
        check(await guest.evaluate('!document.querySelector(".ts-review-comment script") && document.querySelector(".ts-review-list").textContent.includes("<script>")'),'stored HTML remains escaped text in real browser DOM');
        for (const width of [1440,1200,1024,768,390,320]) {
            await guest.viewport(width);
            const layout = await guest.evaluate(`(() => { const section=document.querySelector('.ts-reviews'), form=document.querySelector('.ts-review-compose'), r=form.getBoundingClientRect(); return {fits:section.scrollWidth<=section.clientWidth+1 && r.left>=-1 && r.right<=innerWidth+1,columns:getComputedStyle(document.querySelector('.ts-reviews-layout')).gridTemplateColumns.split(' ').length}; })()`);
            check(layout.fits && layout.columns===(width>=1200?2:1),'review layout fits viewport '+width+'px without horizontal overflow: '+JSON.stringify(layout));
        }
        const blocked = await page(); await login(blocked,'C'); await blocked.navigate('/product-detail?id='+product);
        check(await blocked.evaluate('!document.querySelector("[data-review-form]") && document.querySelector(".ts-review-compose").textContent.includes("sau khi đơn hàng được hoàn tất")'),'ineligible customer sees designed access state without form');
        const customer = await page(); await login(customer,'A'); await customer.viewport(1440);
        await customer.navigate('/product-detail?id='+product+'#review-form');
        check(await customer.evaluate('document.querySelector("input[name=rating]:checked").value==="4" && document.querySelector("[data-review-submit-label]").textContent.includes("Cập nhật")'),'existing DB review is preselected for edit');
        check(await customer.evaluate('getComputedStyle(document.querySelector("#review-form")).outlineStyle==="none"'),'history deep link does not draw a blue outline around the form card');
        await customer.navigate('/product-detail?id='+emptyProduct+'#review-form');
        check(await customer.evaluate('!document.querySelector("input[name=rating]:checked") && document.querySelector("[data-review-counter]").textContent.trim()==="0 / 500 ký tự"'),'new review has no default rating and starts at zero characters');
        await customer.click('[data-review-form] button[type=submit]');
        check(await customer.evaluate('!document.querySelector("[data-review-validation]").hidden && !document.querySelector("[data-review-form]").hasAttribute("aria-busy")'),'native required validation shows error instead of fake submission');
        const descriptions=['Rất tệ','Chưa tốt','Bình thường','Tốt','Tuyệt vời'];
        for (let rating=1;rating<=5;rating++) {
            await customer.click('label[for="ts-review-rating-'+rating+'"]');
            check(await customer.evaluate(`document.querySelector('input[name=rating]:checked').value==='${rating}' && document.querySelector('#ts-review-rating-feedback').textContent===${JSON.stringify(descriptions[rating-1])}`),'mouse selection '+rating+' stars updates feedback without submitting');
        }
        await customer.evaluate('document.querySelector("#ts-review-rating-1").focus()');
        await customer.send('Input.dispatchMouseEvent',{type:'mouseMoved',x:10,y:10});
        await customer.key('ArrowRight','ArrowRight',39);
        check(await customer.evaluate('document.querySelector("input[name=rating]:checked").value==="2" && getComputedStyle(document.querySelector("label:has(input:focus-visible)")).outlineStyle==="solid"'),'native arrow-key rating selection and visible focus work');
        await customer.click('label[for="ts-review-rating-4"]');
        await pause(220);
        check(await customer.evaluate('getComputedStyle(document.querySelector("label[for=ts-review-rating-4]")).color==="rgb(232, 163, 38)"'),'pointer hover gives clear gold star feedback');
        await customer.send('Input.dispatchMouseEvent',{type:'mouseMoved',x:10,y:10}); await pause(220);
        check(await customer.evaluate('getComputedStyle(document.querySelector("label[for=ts-review-rating-1]")).color==="rgb(244, 181, 68)" && getComputedStyle(document.querySelector("label[for=ts-review-rating-5]")).color!=="rgb(244, 181, 68)"'),'selected stars remain gold with unselected star distinct');
        await customer.click('#ts-review-comment-input');
        await customer.send('Input.insertText',{text:'Trải nghiệm giao diện thực tế'});
        check(await customer.evaluate('document.querySelector("[data-review-counter]").textContent.startsWith(document.querySelector("textarea[name=comment]").value.length+" / 500")'),'real textarea input updates character counter');
        check(await customer.evaluate('getComputedStyle(document.querySelector("textarea[name=comment]")).outlineStyle==="none" && getComputedStyle(document.querySelector("textarea[name=comment]")).boxShadow!=="none"'),'textarea uses a soft focus ring');
        await customer.send('Emulation.setEmulatedMedia',{features:[{name:'prefers-reduced-motion',value:'reduce'}]});
        check(await customer.evaluate('getComputedStyle(document.querySelector(".ts-review-rating-option")).transitionDuration==="0s"'),'reduced-motion preference disables decorative transitions');
        await customer.send('Emulation.setEmulatedMedia',{features:[]});
        await customer.click('[data-review-form] button[type=submit]');
        await customer.waitFor('document.readyState==="complete" && !!document.querySelector(".ts-review-success")','persisted create success after server PRG');
        check(await customer.evaluate('document.querySelector(".ts-review-comment").textContent.includes("Trải nghiệm giao diện thực tế") && document.querySelector("input[name=rating]:checked").value==="4"'),'browser submits real fixture review and DB-backed edit form reloads');
        await customer.click('#ts-review-comment-input');
        await customer.evaluate('document.querySelector("#ts-review-comment-input").select()');
        await customer.send('Input.insertText',{text:'Đã cập nhật từ trình duyệt kiểm thử'});
        await customer.click('label[for="ts-review-rating-5"]');
        await customer.click('[data-review-form] button[type=submit]');
        await customer.waitFor('document.readyState==="complete" && !!document.querySelector(".ts-review-comment") && document.querySelector(".ts-review-comment").textContent.includes("Đã cập nhật từ trình duyệt kiểm thử")','persisted review update');
        check(await customer.evaluate('document.querySelectorAll(".ts-review-item").length===1 && document.querySelector("input[name=rating]:checked").value==="5"'),'browser updates same review without duplicating it');
        check(errors.length===0,'no JavaScript runtime errors in guest, customer and access-state pages');
        console.log('ALL PREMIUM REVIEW BROWSER CHECKS PASSED: '+assertions);
    } finally {
        connections.forEach(connection=>connection.close());
        for (const context of contexts) await browser.send('Target.disposeBrowserContext',{browserContextId:context}).catch(()=>{});
        browser.close();
    }
})().catch(error => { console.error(error.stack || error.message); process.exitCode=1; });
