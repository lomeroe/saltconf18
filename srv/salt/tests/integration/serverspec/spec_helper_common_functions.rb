require 'io/console'

def getserver
    print "Enter servername:  "
    return STDIN.gets.chomp
end

def getpw
    print "Enter password:  "
    return STDIN.noecho(&:gets).chomp
end

def getkeys
    print "Enter a comma delimited list of key location(s):  "
    keys = STDIN.gets.chomp
    keys = keys.split(',')
    return keys
end

def getuser
    print "Enter username:  "
    return STDIN.gets.chomp
end

def getauthmethod
    print "Enter a comma delimited set of auth methods (keyboard-interactive/publickey/hostbased/password) [publickey]:  "
    auth_methods = STDIN.gets.chomp
    if auth_methods.empty?
        auth_methods = 'publickey'
    end
    auth_methods = auth_methods.split(',')
    return auth_methods
end

def getport
    print "Use SSL [Yes]:  "
    port = STDIN.gets.chomp
    if port =~ /(?i)no/
        return 5985
    else
        return 5986
    end
end
