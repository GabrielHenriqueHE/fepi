$(document).ready(function() {
    $('.customer-link').click(function(e) {
        e.preventDefault()

        let customerId = $(this).data('customer-id')

        $.ajax({
            url: '/rentals/' + customerId + '/json',
            type: 'GET',
            success: function(data) {
                $('#modalContent').html(data.html)
                $('#rentalModal').modal('show')
            },
            error: function(xhr, status, error) {
                console.error('Error: ', error)
                alert('Failed to load rental details.')
            }
        })
    })
})