import Rails from "@rails/ujs";
import Turbolinks from "turbolinks";
import * as ActiveStorage from "@rails/activestorage";

import "bootstrap";
import "bootstrap/dist/css/bootstrap.min.css";

import "../src/components/HelloReact"; 
import '../stylesheets/Main.css';

Rails.start();
Turbolinks.start();
ActiveStorage.start();
