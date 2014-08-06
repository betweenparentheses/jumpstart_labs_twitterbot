require 'jumpstart_auth'
require 'bitly'

class MicroBlogger
  attr_reader :client

  def initialize
    puts "Initializing MicroBlogger"
    @client = JumpstartAuth.twitter
    Bitly.use_api_version_3
    @bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
  end

  def tweet(message)
      if message.length <= 140
        @client.update(message)
      else
        puts "WARNING: Tweet too long to post."
      end
  end

  def followers_list
    @client.followers.collect { |follower| follower.screen_name }
  end

  def everyones_latest_tweet
    friends = @client.friends.sort_by {|friend| friend.screen_name.downcase}

    friends.each do |friend|
      timestamp = friend.status.created_at
      time_string = timestamp.strftime("%A, %b %d")
      status = friend.status.text

      puts "#{friend.screen_name} said this on #{time_string}..."
      puts status
      puts "" #blank line to separate people
    end
  end

  def shorten(original_url)
    puts "Shortening this URL: #{original_url}"
    @bitly.shorten(original_url).short_url
  end

  def spam_my_followers(message)
    followers_list.each { |follower| dm(follower, message) }
  end

  def dm(target, message)
    puts "Trying to send #{target} this direct message:"
    puts message
    if followers_list.include?(target)
      message = "d @#{target} #{message}"
      tweet(message)
    else
      puts "Sorry, you can only DM people who follow you."
    end
  end

  def run
    puts "Welcome to the JSL Twitter Client!"
    command = ""
    while command != "q"
      printf "enter command: "
      input = gets.chomp

      parts = input.split(" ")
      command = parts[0]

      case command
      when 'q' then puts "Goodbye!"
      when 't' then tweet(parts[1..-1].join(" "))
      when 'dm' then dm(parts[1], parts[2..-1].join(" "))
      when 'spam' then spam_my_followers(parts[1..-1].join(" "))
      when 'latest' then everyones_latest_tweet
      when 's' then shorten(parts[1..-1].join(" "))
      when 'turl' then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
      else
        puts "Sorry, I don't know how to #{command}."
      end
    end
  end
end

#execution script

blogger = MicroBlogger.new
blogger.run
