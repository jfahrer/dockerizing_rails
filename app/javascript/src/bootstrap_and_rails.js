import Rails from "rails-ujs";
import Turbolinks from "turbolinks";

Rails.start();
Turbolinks.start();

import "./application.scss";
import "bootstrap";

$(document).ready(function() {
  $("#nightModeSwitch").change(function() {
    $("html").toggleClass("dark");
    $("nav").toggleClass("navbar-light");
    $("nav").toggleClass("navbar-dark");
    $("nav").toggleClass("bg-light");
    $("nav").toggleClass("bg-dark");
  });
});
