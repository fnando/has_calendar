require File.dirname(__FILE__) + "/lib/has_calendar"
require "stringio"

ActionView::Base.send :include, SimplesIdeias::Calendar::ActionView