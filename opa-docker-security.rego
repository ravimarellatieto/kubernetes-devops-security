package main

suspicious_env_keys = [
    "passwd",
    "password",
    "secret",
    "key",
    "access",
    "api_key",
    "apikey",
    "token",
]

pkg_update_commands = [
    "apk upgrade",
    "apt-get upgrade",
    "dist-upgrade",
]

image_tag_list = [
    "latest",
    "LATEST",
]

# Looking for suspicious environment variable settings
deny[msg] {    
    dockerenvs := [val | input[i].Cmd == "env"; val := input[i].Value]
    dockerenv := dockerenvs[_]
    envvar := dockerenv[_]
    lower(envvar) == suspicious_env_keys[_]
    msg = sprintf("Potential secret in ENV found: %s", [envvar])
}

# Looking for suspicious environment variable settings
deny[msg] {
    dockerenvs := [val | input[i].Cmd == "env"; val := input[i].Value]
    dockerenv := dockerenvs[_]
    envvar := dockerenv[_]
    startswith(lower(envvar), suspicious_env_keys[_])
    msg = sprintf("Potential secret in ENV found: %s", [envvar])
}

# Looking for suspicious environment variable settings
deny[msg] {
    dockerenvs := [val | input[i].Cmd == "env"; val := input[i].Value]
    dockerenv := dockerenvs[_]
    envvar := dockerenv[_]
    endswith(lower(envvar), suspicious_env_keys[_])
    msg = sprintf("Potential secret in ENV found: %s", [envvar])
}

# Looking for suspicious environment variable settings
deny[msg] {
    dockerenvs := [val | input[i].Cmd == "env"; val := input[i].Value]
    dockerenv := dockerenvs[_]
    envvar := dockerenv[_]
    parts := regex.split("[ :=_-]", envvar)
    part := parts[_]
    lower(part) == suspicious_env_keys[_]
    msg = sprintf("Potential secret in ENV found: %s", [envvar])
}

# Looking for latest docker image used
warn[msg] {
    input[i].Cmd == "from"
    val := split(input[i].Value[0], ":")
    count(val) == 1
    msg = sprintf("Do not use latest tag with image: %s", [val])
}

# Looking for latest docker image used
warn[msg] {
    input[i].Cmd == "from"
    val := split(input[i].Value[0], ":")
    contains(val[1], image_tag_list[_])
    msg = sprintf("Do not use latest tag with image: %s", [input[i].Value])
}

# Looking for apk upgrade command used in Dockerfile
deny[msg] {
    input[i].Cmd == "run"
    val := concat(" ", input[i].Value)
    contains(val, pkg_update_commands[_])
    msg = sprintf("Do not use upgrade commands: %s", [val])
}

# Looking for ADD command instead using COPY command
deny[msg] {
    input[i].Cmd == "add"
    val := concat(" ", input[i].Value)
    msg = sprintf("Use COPY instead of ADD: %s", [val])
}

# sudo usage
deny[msg] {
    input[i].Cmd == "run"
    val := concat(" ", input[i].Value)
    contains(lower(val), "sudo")
    msg = sprintf("Avoid using 'sudo' command: %s", [val])
}

# # No Healthcheck usage
# deny[msg] {
#     input[i].Cmd == "healthcheck"
#     msg := "no healthcheck"
# }



# Do not use ADD if possible
deny[msg] {
    input[i].Cmd == "add"
    msg = sprintf("Line %d: Use COPY instead of ADD", [i])
}

# Any user...
any_user {
    input[i].Cmd == "user"
 }

deny[msg] {
    not any_user
    msg = "Do not run as root, use USER instead"
}

# ... but do not root
forbidden_users = [
    "root",
    "toor",
    "0"
]

#deny[msg] {
#    command := "user"
#    users := [name | input[i].Cmd == "user";
#    name := input[i].Value]
#    dockerenvs := [val | input[i].Cmd == "env"; val := input[i].Value]
#    lastuser := users[count(users)-1]
#    contains(lower(lastuser[_]), forbidden_users[_])
#    msg = sprintf("Line %d: Last USER directive (USER %s) is forbidden", [i, lastuser])
#}
