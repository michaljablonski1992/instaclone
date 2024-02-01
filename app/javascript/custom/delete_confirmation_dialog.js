window.addEventListener(('turbo:render'), (e) => {
  console.log(e);
})

window.addEventListener(('turbo:load'), () => {
  document.addEventListener('submit', (event) => {
    if (event.target && event.target.className === 'dbl-delete-alertbox') {
      event.preventDefault()
      const swal = Swal.mixin({
        title: are_u_sure_trans,
        text: no_reverse_trans,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: yes_delete_trans,
        cancelButtonText: cancel_trans
      })
      swal.fire().then((result) => {
        if (result.isConfirmed) {
          swal.fire({text: final_confirm_info_trans}).then((result) => {
            if (result.isConfirmed) {
              document.querySelector('.dbl-delete-alertbox').submit()
            }
          })
          .catch(event.preventDefault())
        }
      })
      .catch(event.preventDefault())
    }
  })
})