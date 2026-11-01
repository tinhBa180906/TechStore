/* Local fixture-only Chrome print verification. PDF artifacts stay in ignored build/, never served. */
'use strict';
const assert = require('node:assert/strict');
const fs = require('node:fs');
const base = process.env.INVOICE_TEST_BASE;
const username = process.env.INVOICE_TEST_USERNAME;
const password = process.env.INVOICE_TEST_PASSWORD;
const order = Number(process.env.INVOICE_TEST_ORDER);
const longOrder = Number(process.env.INVOICE_TEST_LONG_ORDER);
if (!base || !username || !password || !order || !longOrder) throw Error('Run only through local InvoiceIntegrationTest --print fixtures.');
const pause = ms => new Promise(resolve => setTimeout(resolve,ms));
let checks=0;
function check(value,label) { assert.ok(value,label); checks++; console.log('PRINT PASS '+label); }

class CDP {
    static async connect(url) {
        const c = new CDP(); c.socket=new WebSocket(url); c.pending=new Map(); c.listeners=new Map(); c.id=0;
        c.socket.addEventListener('message',event=> {
            const message=JSON.parse(event.data);
            if (message.id) {
                const pending=c.pending.get(message.id); if (!pending) return;
                clearTimeout(pending.timeout); c.pending.delete(message.id);
                if (message.error) pending.reject(Error(message.error.message)); else pending.resolve(message.result);
            } else (c.listeners.get(message.method)||[]).forEach(handler=>handler(message.params));
        });
        await new Promise((resolve,reject)=>{c.socket.addEventListener('open',resolve,{once:true});c.socket.addEventListener('error',reject,{once:true});});
        return c;
    }
    send(method,params={}) {
        const id=++this.id;
        return new Promise((resolve,reject)=> {
            const timeout=setTimeout(()=>{this.pending.delete(id);reject(Error('CDP timeout '+method));},15000);
            this.pending.set(id,{resolve,reject,timeout}); this.socket.send(JSON.stringify({id,method,params}));
        });
    }
    on(method,handler) { const list=this.listeners.get(method)||[];list.push(handler);this.listeners.set(method,list); }
    async evaluate(expression) {
        const data=await this.send('Runtime.evaluate',{expression,returnByValue:true,awaitPromise:true});
        if (data.exceptionDetails) throw Error(data.exceptionDetails.exception?.description||data.exceptionDetails.text);
        return data.result.value;
    }
    async waitFor(expression) { for(let i=0;i<80;i++){if(await this.evaluate(expression))return;await pause(100);}throw Error('Browser condition timed out'); }
    async navigate(id) { await this.send('Page.navigate',{url:base+'/invoice?orderId='+id});await this.waitFor(`document.readyState==='complete' && document.querySelector('[data-invoice-id]')?.dataset.invoiceId==='${id}'`); }
}

(async()=> {
    const version=await(await fetch('http://127.0.0.1:9225/json/version')).json();
    const browser=await CDP.connect(version.webSocketDebuggerUrl);
    let page, context;
    const errors=[];
    try {
        context=(await browser.send('Target.createBrowserContext')).browserContextId;
        const target=await browser.send('Target.createTarget',{url:'about:blank',browserContextId:context});
        const list=await(await fetch('http://127.0.0.1:9225/json/list')).json();
        page=await CDP.connect(list.find(item=>item.id===target.targetId).webSocketDebuggerUrl);
        page.on('Runtime.exceptionThrown',event=>errors.push(event.exceptionDetails.text));
        await page.send('Page.enable');await page.send('Runtime.enable');
        await page.send('Page.navigate',{url:base+'/login'});
        await page.waitFor('document.readyState==="complete" && !!document.querySelector("input[name=username]")');
        const login=await page.evaluate(`fetch(${JSON.stringify(base+'/login')},{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:new URLSearchParams(${JSON.stringify({username,password})}).toString()}).then(r=>r.status)`);
        check(login===200,'fixture customer authenticates in isolated browser context');
        await page.navigate(order);
        check(await page.evaluate('document.querySelectorAll("[data-invoice-line]").length===2 && !document.querySelector(".ts-header")'),'standalone invoice contains both DB lines and no website navigation');
        check(await page.evaluate('!document.querySelector(".invoice-document script") && document.querySelector(".invoice-document").textContent.includes("<script>")'),'buyer/product HTML escaped as text in browser');
        for(const width of [1440,1024,768,390,320]) {
            await page.send('Emulation.setDeviceMetricsOverride',{width,height:1100,deviceScaleFactor:1,mobile:width<768});
            await pause(80);
            check(await page.evaluate('document.documentElement.scrollWidth<=innerWidth+1'),'web layout fits '+width+'px; mobile table scroll stays inside document');
        }
        await page.send('Emulation.setDeviceMetricsOverride',{width:1440,height:1100,deviceScaleFactor:1,mobile:false});
        await page.evaluate('window.__invoicePrintCalled=false;window.print=()=>{window.__invoicePrintCalled=true;};document.querySelector(".invoice-print-button").click()');
        check(await page.evaluate('window.__invoicePrintCalled===true'),'print button calls window.print');
        await page.send('Emulation.setEmulatedMedia',{media:'print'});
        check(await page.evaluate('getComputedStyle(document.querySelector(".invoice-toolbar")).display==="none" && getComputedStyle(document.querySelector(".invoice-print-hint")).display==="none"'),'print mode hides all action controls and screen-only hint');
        check(await page.evaluate('getComputedStyle(document.querySelector(".invoice-document")).boxShadow==="none" && getComputedStyle(document.querySelector(".invoice-items thead")).display==="table-header-group"'),'paper layout has no screen shadow and repeats table header');
        check(await page.evaluate('getComputedStyle(document.querySelector(".invoice-items td")).borderTopStyle==="solid" && getComputedStyle(document.querySelector(".invoice-closing")).breakInside==="avoid"'),'table borders and closing-block page-break protection survive print mode');
        fs.mkdirSync('build/invoice-check',{recursive:true});
        for(const [id,file,multipage] of [[order,'invoice-short.pdf',false],[longOrder,'invoice-multipage.pdf',true]]) {
            await page.navigate(id);
            const pdf=await page.send('Page.printToPDF',{preferCSSPageSize:true,displayHeaderFooter:false,printBackground:false});
            const buffer=Buffer.from(pdf.data,'base64');
            fs.writeFileSync('build/invoice-check/'+file,buffer);
            const text=buffer.toString('latin1');
            check(text.startsWith('%PDF-') && text.includes('%%EOF'),'Chrome produced a complete '+file);
            const box=text.match(/\/MediaBox\s*\[\s*0\s+0\s+([\d.]+)\s+([\d.]+)\s*\]/);
            check(!!box && Math.abs(Number(box[1])-595.28)<2 && Math.abs(Number(box[2])-841.89)<2,file+' uses physical A4 dimensions');
            const pages=(text.match(/\/Type\s*\/Page\b/g)||[]).length;
            check(multipage?pages>=2:pages===1,file+' page count appropriate: '+pages);
            if(multipage)check(await page.evaluate('document.querySelectorAll("[data-invoice-line]").length===38'),'multi-page invoice includes every database line');
        }
        check(errors.length===0,'no invoice-page JavaScript errors');
        console.log('ALL INVOICE BROWSER/PRINT CHECKS PASSED: '+checks);
    } finally {
        if(page)page.socket.close();
        if(context)await browser.send('Target.disposeBrowserContext',{browserContextId:context}).catch(()=>{});
        browser.socket.close();
    }
})().catch(error=>{console.error(error.stack||error.message);process.exitCode=1;});
