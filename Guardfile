guard 'rspec', :version => 2 do
    watch(%r{^spec/.+_spec\.rb$})
    watch('lib/vault-client.rb') { "spec" }
    watch(%r{^lib/(.+)\.rb$}) { |l| "spec/#{l[1]}_spec.rb" }
end
