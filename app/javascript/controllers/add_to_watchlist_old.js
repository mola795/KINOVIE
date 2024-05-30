// document.addEventListener('DOMContentLoaded', () => {
//   document.querySelectorAll('.btn-add-watchlist').forEach(button => {
//     button.addEventListener('click', function() {
//       const titleId = this.dataset.titleId;

//       fetch(`/add_to_watchlist?title_id=${titleId}`, {
//         method: 'POST',
//         headers: {
//           'X-CSRF-Token': document.querySelector('[name=csrf-token]').content,
//           'Content-Type': 'application/json'
//         }
//       })
//       .then(response => response.json())
//       .then(data => {
//         if (data.success) {
//           alert('Title was added to your Watchlist.');
//           this.innerHTML = '<i class="fa-solid fa-check"></i>';
//         } else {
//           alert('There was an error adding the title to your Watchlist.');
//         }
//       });
//     });
//   });
// });
