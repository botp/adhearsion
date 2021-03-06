# encoding: utf-8

class DemoApp < Adhearsion::Application
  plugin_name :demo

  # Actions to perform when initialising the application
  #
  init do
    logger.info "This is the Adhearsion Demo application as generated by `ahn create`. It should work well on FreeSWITCH, and will soon also work on Asterisk."
  end

  # Basic configuration for the application
  #
  config do
    greeting "Hello. Welcome to the Simon Game. Lets play.", desc: "What to use to greet users before playing the Simon Game"
  end
end
