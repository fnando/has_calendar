module SimplesIdeias
  module Calendar
    module ActionView
      def calendar(options={}, &block)
        options = {
          :year => Date.today.year,
          :month => Date.today.month,
          :today => nil,
          :events => nil,
          :field => :created_at,
          :header_format => :day_of_week,
          :caption_format => :default,
          :id => "calendar"
        }.merge(options)

        date, days = Date.new(options[:year], options[:month]), []
        date.beginning_of_month.cwday.times { days << '' }
        date.end_of_month.day.times { |i| days << i + 1 }

        # group all records if data is provided
        if options[:events]
          records = options[:events].inject({}) do |memo, record|
            field = record.send(options[:field])

            if field
              stamp = field.to_date.to_s(:number)
              memo[stamp] ||= []
              memo[stamp] << record
            end

            memo
          end
        end

        # building the calendar
        contents = content_tag(:table, :id => options[:id], :class => 'calendar') do
          # first, get the header
          today = Date.today
          date = today.beginning_of_week
          date = date - 1.day if RUBY_PLATFORM =~ /darwin/

          caption = content_tag(:caption, l(Date.new(options[:year], options[:month]), :format => options[:caption_format]))

          head = content_tag(:thead) do
            content_tag(:tr) do
              (0..6).collect { |i| content_tag(:th, l(date + i.days, :format => options[:header_format])) } * ""
            end
          end

          # then get the body
          rows = ""
          days.in_groups_of(7, "") do |group|
            # skip rows that don't have any days
            next unless group.inject(false) {|m, x| m || !x.blank?}
            rows << content_tag(:tr) do
              group.inject("") do |cols, day|
                col_options = {:class => 'day'}
                events = ""

                unless day.blank?
                  date = Date.new(options[:year], options[:month], day.to_i)
                  col_options[:class] << ' today' if today == date
                  col_options[:class] << ' weekend' if [0,6].include?(date.wday)
                end

                if block_given? && !day.blank?
                  if options[:events]
                    events = capture(date, records[date.to_s(:number)], &block)
                  else
                    events = capture(date, &block)
                  end

                  col_options[:class] << ' events' unless events.blank?
                end

                cols << content_tag(:td, col_options) do
                  day = options[:today] if options[:today] && date == today
                  span = content_tag(:span, day)
                  span + events
                end
              end
            end
          end

          caption + head + rows
        end

        concat(contents) if block_given?

        contents
      end
    end
  end
end
