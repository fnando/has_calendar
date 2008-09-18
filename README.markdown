has_calendar
============

has_calendar is a view helper that creates a calendar using a table. You can 
easily add events with any content.

This plugin relies on the `cal` command, available on *nix systems. Instead 
of calculating dates, I parse the output.

NOTE: Only on Mac OS X (Unix?) the first day of week is Sunday; Linux (tested
on Ubuntu) uses the argument `-m`, starting on Monday.

Want this to work on Windows systems? Make sure you have a command `cal` on 
your PATH that returns exactly the *nix output (haven't tested though).

Instalation
-----------

1) Install the plugin with `script/plugin install git://github.com/fnando/has_calendar.git`

Usage
-----

	<%= calendar :year => 2008, :month => 9 %>

or, if you want to register some events:

	<% calendar :year => 2008, :month => 9 do |date| %>
		<% for event in Schedule.find_by_date(date) %>
			<%= link_to event.title, event_path(event) %>
		<% end %>
	<% end %>

As you can see, this will hit your database up to 31 times (one hit for each 
day) if you don't optimize it. Fortunately, you can use the options `:events`:

	<% calendar :events => Schedule.all do |date, events| %>
		<% for event in events %>
			<%= link_to event.title, event_path(event) %>
		<% end %>
	<% end %>

By default, each record will use the `created_at` attribute as date grouping. 
You can specify a different attribute with the option `:field`:

	<% calendar :events => Schedule.all, :field => :scheduled_at do |date, events| %>
		<!-- do something -->
	<% end %>

Formatting the calendar
-----------------------

You can use this CSS to start:

	#calendar {
		border-collapse: collapse;
		width: 100%;
	}

	#calendar td,
	#calendar th {
		color: #ccc;
		font-family: "Lucida Grande",arial,helvetica,sans-serif;
		font-size: 10px;
		padding: 6px;
	}

	#calendar th {
		border: 1px solid #ccc;
		background: #ccc;
		color: #666;
		text-align: left;
	}

	#calendar td {
		background: #f0f0f0;
		border: 1px solid #ddd;
	}

	#calendar span {
		display: block;
	}

	#calendar td.events {
		background: #fff;
	}

	#calendar td.today {
		background: #ffc;
		color: #666;
	}

	#calendar caption {
	  display: none;
	}

TO-DO
-----

- Write some specs as soon as possible!

Copyright (c) 2008 Nando Vieira, released under the MIT license