echo Primary: my-release-mysql-primary.default.svc.cluster.local:3306
echo Secondary: my-release-mysql-secondary.default.svc.cluster.local:3306

Tip:

  Watch the deployment status using the command: kubectl get pods -w --namespace default

Services:

  echo Primary: my-release-mysql-primary.default.svc.cluster.local:3306
  echo Secondary: my-release-mysql-secondary.default.svc.cluster.local:3306

Execute the following to get the administrator credentials:

  echo Username: root
  MYSQL_ROOT_PASSWORD=$(kubectl get secret --namespace default my-release-mysql -o jsonpath="{.data.mysql-root-password}" | base64 -d)

To connect to your database:

  1. Run a pod that you can use as a client:

      kubectl run my-release-mysql-client --rm --tty -i --restart='Always' --image  docker.io/bitnami/mysql:8.0.30-debian-11-r27 --namespace default --env MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD --command -- bash 

  2. To connect to primary service (read/write):

      mysql -h my-release-mysql-primary.default.svc.cluster.local -uroot -p"$MYSQL_ROOT_PASSWORD"

  3. To connect to secondary service (read-only):

      mysql -h my-release-mysql-secondary.default.svc.cluster.local -uroot -p"$MYSQL_ROOT_PASSWORD"

      mysq -uroot -p"$MYSQL_ROOT_PASSWORD"