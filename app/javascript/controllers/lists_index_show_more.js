document.addEventListener('DOMContentLoaded', function() {
  var collapseElement = document.getElementById('collapseLists');
  var toggleButton = document.getElementById('toggleButton');

  collapseElement.addEventListener('show.bs.collapse', function () {
    toggleButton.textContent = 'Show Less';
  });

  collapseElement.addEventListener('hide.bs.collapse', function () {
    toggleButton.textContent = 'Show More';
  });

  // Update the button text based on initial state
  var isCollapsed = !collapseElement.classList.contains('show');
  toggleButton.textContent = isCollapsed ? 'Show More' : 'Show Less';
});
