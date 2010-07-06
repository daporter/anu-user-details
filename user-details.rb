require "rubygems"
require "sinatra"
require "haml"
require "net/ldap"

get "/" do
  haml :search
end

get "/search" do
  if params[:email] or params[:uni_id]
    filter = Net::LDAP::Filter.eq("mail", params[:email])  if params[:email]
    filter = Net::LDAP::Filter.eq("uid", params[:uni_id])  if params[:uni_id]

    ldap = Net::LDAP.new(:host       => "ldap.anu.edu.au",
                         :port       => 636,
                         :encryption => :simple_tls)

    @entries = ldap.search(:base       => "ou=people,o=anu.edu.au",
                           :filter     => filter,
                           :attributes => ["mail", "cn", "uid"])

    @msg = "No results"  if @entries.empty?
  end

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
            %th{:style => "text-align: left;"} Uni ID(s)
          %tbody
            - @entries.each do |e|
              %tr
                %td{:style => "padding-right: 10px;"}= e.cn.first
                %td{:style => "padding-right: 10px;"}= e.mail.first
                %td= e.uid.join(", ")
