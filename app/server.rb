require 'sinatra'

set :host_authorization, { permitted_hosts: [] }

get '/' do
  'It fuckin works!'
end