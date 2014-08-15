module Krill

  class ThreadStatus
    attr_accessor :running
  end

  class Manager

    attr_accessor :thread

    def initialize jid

      # Start new thread
      @mutex = Mutex.new
      @thread_status = ThreadStatus.new
      @thread_status.running = false

      # Get job info
      @jid = jid
      @job = Job.find(jid)
      @code = Repo::contents @job.path, @job.sha
      initial_state = JSON.parse @job.state, symbolize_names: true
      @args = initial_state[0][:arguments]

      # Create Namespace
      @namespace = Krill::make_namespace @code

      # Add base_class ancestor to user's code
      @base_class = make_base
      insert_base_class @namespace, @base_class

      # Make a base object
      @base_object = Class.new.extend(@base_class)

      # Make protocol
      @protocol = @namespace::Protocol.new

    end

    ##################################################################################
    # TRICKY THREAD STUFF
    #

    def start_thread

      @thread_status.running = true

      @thread = Thread.new {

        begin

          @job.reload.pc = 0
          @job.save

          begin

            rval = @protocol.main

          rescue Exception => e

            puts "#{@job.id}: EXCEPTION #{e.to_s} + #{e.backtrace[0,10]}"
            @base_object.error e

          else

            @job.reload.append_step operation: "complete", rval: rval 

          ensure

            @job.reload.pc = Job.COMPLETED
            @job.save
            
            ActiveRecord::Base.connection.close

            @mutex.synchronize { @thread_status.running = false }

          end

        rescue Exception => main_error

          puts "#{@job.id}: SERIOUS EXCEPTION #{main_error.to_s}: #{main_error.backtrace[0,10]}"

        end

      }

    end

    def run
      start_thread
      wait 20
    end

    def wait secs

      n = 0
      running = true
      @mutex.synchronize { running = @thread_status.running }

      while running
        return "not_ready" unless n < 10*secs # wait two seconds
        n += 1
        sleep(0.1) 
        @mutex.synchronize { running = @thread_status.running }
      end

      @job.reload

      if @job.pc == -2
        return "done"
      else
        return "ready"
      end

    end

    def check_again

      if @thread.alive?
        wait 2
      else 
        "done"
      end

    end

    def continue

      if @thread.alive?

        @mutex.synchronize do
          unless @thread_status.running     # The intention here is that if the step didn't complete in the last
            @thread_status.running = true   # continue, then it would still be running for the next. However, if
            @thread.wakeup                  # the user waits long enough before trying again, then the step might
          end                               # be done, and this will do another step, resulting in two steps in a
        end                                 # row. Better would be to have the javascript request a different version
                                            # of continue for the second time "OK" is clicked. 
        wait 2

      else 

        "done"

      end

    end

    def stop

      @thread.kill
      @thread_status.running = false
      state = JSON.parse @job.state, symbolize_names: true
      job = Job.find(jid)
      steps = []

      if state.length % 2 == 0 # backtrace ends with a 'next'
        # add incomplete step
        steps.push operation: "display", content: [ { title: "Interrupted" } ]
      end

      # add next
      steps.push operation: "next", time: Time.now, inputs: i 

      # and final step
      steps.push operation: "aborted", rval: {}

      job.append_steps steps

    end

    #
    # END TRICKY THREAD STUFF
    ###########################################################################

    def make_base

      b = Module.new
      b.send(:include,Base)
      b.module_eval "def jid; #{@jid}; end"
      b.module_eval "def input; #{@args}; end"

      manager_mutex = @mutex
      b.send :define_method, :mutex do
        manager_mutex
      end

      manager_thread_status = @thread_status
      b.send :define_method, :thread_status do
        manager_thread_status
      end

      b

    end

    def insert_base_class obj, mod

      obj.constants.each do |c|

        k = obj.const_get(c)

        if k.class == Module
          eigenclass = class << self
            self
          end
          eigenclass.send(:include,mod) unless eigenclass.include? mod
          insert_base_class k, mod
        elsif k.class == Class
          k.send(:include,mod) unless k.include? mod
          insert_base_class k, mod
        end

      end

    end

  end

end
