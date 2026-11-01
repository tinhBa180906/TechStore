/* Progressive UI only: native POST/CSRF, server validation and persisted success stay unchanged. */
(() => {
    'use strict';
    document.querySelectorAll('[data-review-section]').forEach(section => {
        const form = section.querySelector('[data-review-form]');
        if (!form) return;
        const ratings = Array.from(form.querySelectorAll('input[name="rating"]'));
        const fieldset = form.querySelector('.ts-review-rating-field');
        const feedback = form.querySelector('.ts-review-rating-feedback');
        const comment = form.querySelector('textarea[name="comment"]');
        const counter = form.querySelector('[data-review-counter]');
        const validation = form.querySelector('[data-review-validation]');
        const button = form.querySelector('button[type="submit"]');
        const label = form.querySelector('[data-review-submit-label]');
        const submitStatus = form.querySelector('[data-review-submit-status]');
        const originalLabel = label.textContent.trim();
        const descriptions = ['', 'Rất tệ', 'Chưa tốt', 'Bình thường', 'Tốt', 'Tuyệt vời'];

        function updateRating() {
            const selected = ratings.find(rating => rating.checked);
            feedback.textContent = selected ? descriptions[Number(selected.value)] : 'Chạm vào sao để chọn mức đánh giá';
            feedback.dataset.selected = selected ? 'true' : 'false';
            fieldset.classList.remove('is-invalid');
            if (selected) { validation.hidden = true; validation.textContent = ''; }
        }
        function updateComment() {
            counter.textContent = comment.value.length + ' / ' + comment.maxLength + ' ký tự';
            counter.dataset.atLimit = comment.value.length >= comment.maxLength ? 'true' : 'false';
            comment.setCustomValidity('');
            comment.removeAttribute('aria-invalid');
            validation.hidden = true;
            validation.textContent = '';
        }
        ratings.forEach(rating => rating.addEventListener('change', updateRating));
        comment.addEventListener('input', updateComment);
        form.addEventListener('invalid', event => {
            const isRating = event.target.name === 'rating';
            if (isRating) fieldset.classList.add('is-invalid');
            else if (event.target === comment) comment.setAttribute('aria-invalid', 'true');
            validation.textContent = isRating ? 'Vui lòng chọn mức đánh giá từ 1 đến 5 sao.' : 'Vui lòng nhập nhận xét tối đa 500 ký tự.';
            validation.hidden = false;
        }, true);
        form.addEventListener('submit', event => {
            if (form.dataset.submitting === 'true') { event.preventDefault(); return; }
            if (!comment.value.trim()) {
                event.preventDefault();
                comment.setCustomValidity('Vui lòng nhập nhận xét của bạn.');
                comment.setAttribute('aria-invalid', 'true');
                comment.reportValidity();
                return;
            }
            form.dataset.submitting = 'true';
            form.setAttribute('aria-busy', 'true');
            button.disabled = true;
            label.textContent = 'Đang gửi…';
            submitStatus.textContent = 'Đang lưu đánh giá của bạn.';
            // Allow the browser's original form POST and server PRG; never simulate success here.
        });
        window.addEventListener('pageshow', () => {
            delete form.dataset.submitting;
            form.removeAttribute('aria-busy');
            button.disabled = false;
            label.textContent = originalLabel;
            submitStatus.textContent = '';
            updateRating();
            updateComment();
        });
        updateRating();
        updateComment();
    });
})();
