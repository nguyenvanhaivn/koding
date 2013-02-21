name "web-server"
description "The  role for WEB servers"

env_run_lists "prod-webstack-a" => ["role[base_server]",
                                    "recipe[nginx]",
                                    "recipe[kd_deploy::nginx_conf]",
                                    "recipe[nodejs]",
                                    "recipe[golang]",
                                    "recipe[papertrail]",
                                    "recipe[kd_deploy]"
                                   ],
              "prod-webstack-b" => ["role[base_server]",
                                    "recipe[nginx]",
                                    "recipe[kd_deploy::nginx_conf]",
                                    "recipe[nodejs]",
                                    "recipe[golang]",
                                    "recipe[papertrail]",
                                    "recipe[kd_deploy]",
                                   ],
               "_default" => ["role[base_server]",
                                    "recipe[nginx]",
                                    "recipe[kd_deploy::nginx_conf]",
                                    "recipe[nodejs]",
                                    "recipe[golang]",
                                    "recipe[papertrail]",
                                   ]


default_attributes({ 
                     "launch" => {
                                "programs" => ["webserver"],
                                "build_client" => true
                     },
                     "log" => {
                                "files" => ["/var/log/upstart/webserver.log"]       
                     }
})
