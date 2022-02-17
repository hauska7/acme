# rubocop:disable all

# PATCH for error
# $ rspec
# /home/grzegorz/.rvm/gems/ruby-3.1.0/bin/ruby_executable_hooks: warning: Exception in finalizer #<Proc:0x00007f8efcd96088 /home/grzegorz/.rvm/gems/ruby-3.1.0/gems/vcr-6.0.0/lib/vcr/library_hooks/webmock.rb:36 (lambda)>
# /home/grzegorz/.rvm/gems/ruby-3.1.0/gems/vcr-6.0.0/lib/vcr/library_hooks/webmock.rb:36:in `block in global_hook_disabled_requests': wrong number of arguments (given 1, expected 0) (ArgumentError)

if defined? VCR
  fail('Please inspect if this patch is still nesessary') if VCR.version != '6.0.0'

  module VCR
    class LibraryHooks
      module WebMock
        def global_hook_disabled_requests
          requests = @global_hook_disabled_requests[Thread.current.object_id]
          return requests if requests

          ObjectSpace.define_finalizer(Thread.current, Proc.new {
            @global_hook_disabled_requests.delete(Thread.current.object_id)
          })

          @global_hook_disabled_requests[Thread.current.object_id] = []
        end
      end
    end
  end
end

# rubocop:enable all
