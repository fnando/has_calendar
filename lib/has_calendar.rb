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
          :header_format => :day_name
        }.merge(options)
      
        cmd = 'cal '
        cmd << '-m ' unless RUBY_PLATFORM =~ /darwin/
      
        # execute the command
        output = IO.popen("#{cmd} #{options[:month]} #{options[:year]}").read
      
        # get calendar lines
        io = StringIO.new(output)
        lines = io.readlines
        lines = lines[2, lines.size-3]
        lines.map!(&:chomp)
      
        # strip spaces from each day and group them
        days = lines.inject([]) do |holder, line|
          0.step(line.size, 3) do |n|
            holder << line[n, 3].squish
          end
          holder
        end
        
        # group all records if data is provided
        if options[:events]
          records = options[:events].inject({}) do |memo, record|
            stamp = record.send(options[:field]).to_date.to_s(:number)
            memo[stamp] ||= []
            memo[stamp] << record
            memo
          end
        end
      
        # building the calendar
        contents = content_tag(:table, :id => 'calendar') do
        
          # first, get the header
          today = Date.today
          date = today.beginning_of_week
          date = date - 1.day if RUBY_PLATFORM =~ /darwin/
        
          caption = content_tag(:caption, Date.new(options[:year], options[:month], 1).strftime('%B/%Y'))
        
          head = content_tag(:thead) do
            content_tag(:tr) do
              (0..6).collect { |i| content_tag(:th, l(date + i.days, :format => options[:header_format])) } * ""
            end
          end
        
          # then get the body
          rows = ""
          days.in_groups_of(7, "") do |group|
            rows << content_tag(:tr) do
              group.inject("") do |cols, day|
                col_options = {:class => 'day'}
                events = ""
              
                unless day.blank?
                  date = Date.new(options[:year], options[:month], day.to_i)
                  col_options[:class] << ' today' if today == date
                  col_options[:class] << ' weekday' if [0,6].include?(date.wday)
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
      
        concat(contents, block.binding) if block_given?
        contents
      end
    end
  end
end
