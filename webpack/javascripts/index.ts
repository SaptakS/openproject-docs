require('expose-loader?exposes[]=$&exposes[]=jQuery!jquery');
require('popper.js');
require('bootstrap/dist/js/bootstrap.bundle');

import './src/docsearch'
import './src/header_scroll'
import './src/global_nav'
import './src/disabled_search_form'
import './src/class_toggle'
import './src/installation-toggler'
import './src/search-trigger'

// Ensure toc generator comes last
import './src/toc_generator'
