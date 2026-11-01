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

// Payment confirmation stays separate from order delivery actions and existing filters.
(() => {
    'use strict';
    const dialog = document.getElementById('admin-payment-dialog');
    const form = document.getElementById('admin-payment-confirm-form');
    if (!dialog || !form) return;
    const verified = document.getElementById('admin-payment-verified');
    const submit = document.getElementById('admin-payment-final-confirm');
    const label = form.querySelector('[data-admin-payment-submit-label]');
    const reset = () => {
        verified.checked = false;
        submit.disabled = true;
        form.removeAttribute('aria-busy');
        label.textContent = 'Xác nhận nhận tiền';
    };
    document.querySelectorAll('[data-admin-payment-confirm]').forEach(button => {
        button.addEventListener('click', () => {
            reset();
            const id = button.dataset.adminPaymentConfirm;
            document.getElementById('admin-payment-order-id').value = id;
            document.getElementById('admin-payment-dialog-order').textContent = '#' + id;
            document.getElementById('admin-payment-dialog-amount').textContent = button.dataset.adminPaymentAmount + ' ₫';
            document.getElementById('admin-payment-dialog-reference').textContent = 'TECHSTORE' + id;
            dialog.showModal();
        });
    });
    verified.addEventListener('change', () => { submit.disabled = !verified.checked; });
    dialog.querySelectorAll('[data-admin-payment-close]').forEach(button => {
        button.addEventListener('click', () => { if (!form.hasAttribute('aria-busy')) dialog.close(); });
    });
    dialog.addEventListener('cancel', event => { if (form.hasAttribute('aria-busy')) event.preventDefault(); });
    form.addEventListener('submit', event => {
        if (form.hasAttribute('aria-busy') || !verified.checked) { event.preventDefault(); return; }
        form.setAttribute('aria-busy', 'true');
        submit.disabled = true;
        label.textContent = 'Đang xác nhận…';
    });
    window.addEventListener('pageshow', reset);
})();
