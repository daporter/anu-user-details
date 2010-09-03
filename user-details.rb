#!/usr/bin/env ruby

require "rubygems"
require "sinatra"
require "haml"
require "anu-ldap"

set :run, true
enable :inline_templates

get "/" do
  haml :search
end

get "/search" do
  @entries = []
  if params[:email]
    @entries = AnuLdap.find_by_email(params[:email])
  elsif params[:uni_id]
    @entries = AnuLdap.find_by_uni_id(params[:uni_id])
  end

  @msg = "No results"  if @entries.empty?

  haml :search
end

__END__

@@search
%html
  %head
    %title Lookup User
  %body
    %h2 Lookup user details from ANU LDAP

    #search
      %form{:action => "/search", :method => "GET"}
        %label{:for => "email", :style => "padding-right: 5px;"} Search by email:
        %input{:name => "email", :type => "text", :size => "40"}

      %form{:action => "/search", :method => "GET"}
        %label{:for => "uni_id"} Search by Uni ID:
        %input{:name => "uni_id", :type => "text", :size => "40"}

    #entries
      - if @msg
        %strong= @msg

      - if @entries && !@entries.empty?
        %table
          %thead
            %th{:style => "text-align: left;"} Name
            %th{:style => "text-align: left;"} Email
            %th{:style => "text-align: left;"} Uni ID
          %tbody
            - @entries.each do |e|
              %tr
                %td{:style => "padding-right: 10px;"}= e[:full_name]
                %td{:style => "padding-right: 10px;"}= e[:email]
                %td= e[:uni_id]
