(() => {
    'use strict';
    const cards = Array.from(document.querySelectorAll('[data-order-status]'));
    const tabs = Array.from(document.querySelectorAll('[data-filter]'));
    const search = document.getElementById('order-search');
    const result = document.getElementById('order-result-count');
    const empty = document.getElementById('order-no-results');
    if (!search || !result || !empty) return;
    let status = 'ALL';
    const normalize = value => value.toLocaleLowerCase('vi').normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/g, 'd').trim();
    const searchable = cards.map(card => normalize('don #' + card.dataset.orderId + ' ' + card.querySelector('.admin-order-preview').textContent));
    tabs.forEach(tab => {
        tab.querySelector('span').textContent = cards.filter(card => tab.dataset.filter === 'ALL' || card.dataset.orderStatus === tab.dataset.filter).length;
        tab.addEventListener('click', () => {
            status = tab.dataset.filter;
            update();
        });
    });
    function update() {
        const query = normalize(search.value);
        let visible = 0;
        cards.forEach((card, index) => {
            card.hidden = !((status === 'ALL' || card.dataset.orderStatus === status) && searchable[index].includes(query));
            if (!card.hidden) visible++;
        });
        tabs.forEach(tab => {
            const selected = status === tab.dataset.filter;
            tab.classList.toggle('selected', selected);
            tab.setAttribute('aria-pressed', String(selected));
        });
        result.textContent = 'Hiển thị ' + visible + ' / ' + cards.length + ' đơn hàng';
        empty.hidden = cards.length === 0 || visible > 0;
    }
    search.addEventListener('input', update);
    document.getElementById('reset-order-filter').addEventListener('click', () => {
        search.value = '';
        status = 'ALL';
        update();
        search.focus();
    });
    update();
})();
