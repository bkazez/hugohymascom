window.onload = function() {
  const hamburger = document.querySelector(".hamburger-menu");
  const nav = document.querySelector(".nav");

  /* When the hamburger menu is clicked, the navigation menu slides in from the right, and the hamburger menu turns into an X */
  hamburger.addEventListener("click", function() {
    nav.classList.toggle("show");
    hamburger.classList.toggle("open");
  });
}

window.addEventListener('popstate', function(event) {
  document.querySelector('.nav').classList.remove('show');
});