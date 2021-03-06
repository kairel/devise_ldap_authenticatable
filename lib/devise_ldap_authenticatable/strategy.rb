require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    # Strategy for signing in a user based on his login and password using LDAP.
    # Redirects to sign_in page if it's not authenticated
    class LdapAuthenticatable < Authenticatable
      # Authenticate a user based on login and password params, returning to warden
      # success and the authenticated user if everything is okay. Otherwise redirect
      # to sign in page.
      def authenticate!
        if per = Person.where(username: authentication_hash[:username]).first
          unless per.password_smart.nil?
            resource = Person.where(username: authentication_hash[:username], password_smart: Digest::SHA256.hexdigest(password)).first
          else
           resource = valid_password? && mapping.to.authenticate_with_ldap(authentication_hash.merge(:password => password))
          end
        else
          resource = valid_password? && mapping.to.authenticate_with_ldap(authentication_hash.merge(:password => password))
        end
        return fail(:invalid) if resource.nil?
        if validate(resource)
          success!(resource)
        else
          fail(:invalid)
        end
      end
    end
  end
end

Warden::Strategies.add(:ldap_authenticatable, Devise::Strategies::LdapAuthenticatable)
