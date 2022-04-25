#cloud-config
groups:
  - docker
users:
  - name: cs
    ssh_import_id:
      - gh:${github_username}
    lock_passwd: true
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: [docker] # for sudoless docker
    shell: /bin/bash

write_files:
  - path: /etc/ssh/banner
    content: |

      (                                         (     
      )\ )        (            )           (    )\ )  
      (()/(    )   )\ )      ( /(           )\  (()/(  
      /(_))( /(  (()/(  (   )\())    __  (((_)  /(_)) 
      (_))  )(_))  ((_)) )\ ((_)\    / /  )\___ (_))   
      | _ \((_)_   _| | ((_)| |(_)  / /  ((/ __|/ __|  
      |  _// _` |/ _` |/ _ \| / /  /_/    | (__ \__ \  
      |_|  \__,_|\__,_|\___/|_\_\          \___||___/  

        _._     _,-'""`-._
      (,-.`._,'(       |\`-/|
          `-.-' \ )-`( , o o)
                `-    \`_`"'-

                                                      
runcmd:
  # Install banner
  - echo 'Banner /etc/ssh/banner' >> /etc/ssh/sshd_config.d/banner.conf
  - sudo systemctl restart sshd

  # Install docker using convenience script
  # https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script
  # Not suitable for production but good and simple enough for our use case
  - curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
  - sh /tmp/get-docker.sh
  - rm /tmp/get-docker.sh

  # Install docker-compose
  # https://docs.docker.com/compose/install/
  - curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  - chmod +x /usr/local/bin/docker-compose
  # add bash completion
  - curl -L https://raw.githubusercontent.com/docker/compose/1.29.2/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose

  # Install Kubernetes
  # https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
  - curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  - install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  - kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null

  # Install Helm
  - curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

  # Install Kind
  - curl -L https://kind.sigs.k8s.io/dl/v0.12.0/kind-linux-amd64 -o /usr/local/bin/kind
  - chmod +x /usr/local/bin/kind

  # Clone the exercise repository
  - git clone https://github.com/padok-team/dojo-guestbook.git /home/cs/dojo-guestbook

  - curl "https://echo.dixneuf19.me/${github_username}" # telemetry
