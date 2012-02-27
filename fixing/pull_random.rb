require '~/Data-Mining/lib/setup.rb'
require 'awesome_print'
require 'readline'

class App
  @@problem_type = { "0" => "unmatched entity", 
                     "1" => "bad entity matching",
                     "2" => "over matching" }
  @@prompt = "\033[32m%>\033[0m "
  @@commands = { "exit"  => :exit, 
                 "next"  => :next,
                 "start" => :new_doc,
                 "set"   => :set_issue,
                 "print_issues" => :print_issues,
                 "submit" => :submit,
                 "clean" => :clean }
  
  def initialize input
    @input = input
    @db = DB.new 'test'
    @pt_col = @db['parsed_tweets_test']
    @info_col = @db['fixing_info']
    @last_cmd = "next"
    Readline.completion_append_character = " "
    Readline.completion_proc = proc { |s| @@commands.keys.grep( /^#{Regexp.escape(s)}/ ) }
    prompt
  end

  def get_random
    doc = @pt_col.find_one({}, {:limit => 1, :skip => rand(29000)})
    { :tweet_id => doc['tweet_id'], :text => doc['text'], :mappings => doc['mappings'] }
  end

  def print_doc
    system('clear')
    puts ("=" * 80)
    ap(@cdoc)
    puts ("=" * 80)
    puts @@problem_type
  end

  def next
    new_doc  
  end
  
  def exit
    abort("BYE!")
  end

  def new_doc
    @cdoc = get_random
    print_doc
    @issues = []
  end

  def clean
    print_doc
  end

  def set_issue args
    if args.size < 3
      puts "ERROR: set ISSUE_TYPE ENTITY COMMENT"
      return
    end
    (type, entity, *comment) = args
    comment = comment.join(" ")
    @issues << { :type => type, :entity => entity, :comment => comment }
    print_issues
   end

  def print_issues
    puts "Current noted issues:"
    puts @issues
  end

  def process cmd
    cmd = @last_cmd if cmd == ""
    @last_cmd = cmd
    (cmd, *args) = cmd.split(" ")
    if !@@commands.has_key? cmd
      puts "ERROR: No such command [#{cmd}]"
    else
      if args.size > 0
        send @@commands[cmd], args
      else
        send @@commands[cmd]
      end
    end
  end

  def submit
    @issues.each do |issue|
      @info_col.insert(issue.merge({:tweet_id => @cdoc[:tweet_id]}))
    end
    puts "Submited."
  end

  def prompt
    #cli = RCommand.new($stdin, $stdout)
    new_doc
    loop do 
      process Readline::readline(@@prompt, true).strip
    end
  end

end

App.new(STDIN)
