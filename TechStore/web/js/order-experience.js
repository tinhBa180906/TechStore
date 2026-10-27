(() => {
    'use strict';
    const input = document.getElementById('history-search');
    if (!input) return;
    const cards = Array.from(document.querySelectorAll('[data-history-status]'));
    const tabs = Array.from(document.querySelectorAll('[data-history-filter]'));
    const result = document.getElementById('history-result');
    const empty = document.getElementById('history-no-results');
    const normalize = value => value.toLocaleLowerCase('vi').normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/g, 'd').trim();
    const texts = cards.map(card => normalize(card.querySelector('.order-id').textContent + ' ' + Array.from(card.querySelectorAll('.td-product-name')).map(node => node.textContent).join(' ')));
    let status = 'ALL';
    function update() {
        const query = normalize(input.value);
        let visible = 0;
        cards.forEach((card, index) => {
            card.hidden = !((status === 'ALL' || card.dataset.historyStatus === status) && texts[index].includes(query));
            if (!card.hidden) visible++;
        });
        tabs.forEach(tab => {
            const selected = tab.dataset.historyFilter === status;
            tab.classList.toggle('selected', selected);
            tab.setAttribute('aria-pressed', String(selected));
        });
        result.textContent = visible + ' / ' + cards.length + ' đơn hàng';
        empty.hidden = visible > 0;
    }
    tabs.forEach(tab => {
        tab.querySelector('span').textContent = cards.filter(card => tab.dataset.historyFilter === 'ALL' || tab.dataset.historyFilter === card.dataset.historyStatus).length;
        tab.addEventListener('click', () => { status = tab.dataset.historyFilter; update(); });
    });
    input.addEventListener('input', update);
    document.getElementById('history-reset').addEventListener('click', () => {
        input.value = '';
        status = 'ALL';
        update();
        input.focus();
    });
    update();
})();
