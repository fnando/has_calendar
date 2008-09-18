require File.dirname(__FILE__) + "/lib/has_calendar"
require "stringio"

ActiveRecord::Base.send :include, SimplesIdeias::Calendar::ActiveRecord
ActionView::Base.send :include, SimplesIdeias::Calendar::ActionView