#!/bin/sh

SSH_user=fcdb
DB_server=10.72.143.250
DB_user=postgres
DB_name=vols

date_after=`date "+%Y-%m"`-01
date_before=`date "+%Y-%m" -d "-1 month"`-01

req_eks="\\copy ( 
  SELECT exploit_declaration.id, commitee.name
     AS \"Исполком\", region.name
     AS \"Область\", exploit_declaration.object_name
     AS \"Номер\", exploit_declaration.object_number
     AS \"Наименование\", object_status.text
     AS \"Состояние\", exploit_declaration.create_date
     AS \"Создано\", exploit_declaration.register_date
     AS \"Отправлено в НЦОТ\", exploit_declaration.modify_date
     AS \"Последнее изменение\",
     CASE WHEN exploit_declaration.archive = TRUE
       THEN 'Да' ELSE 'Нет' END
     AS \"В архиве\"
     FROM public.exploit_declaration, public.object_status, public.commitee, public.region
     WHERE exploit_declaration.declaration_status = object_status.id
       AND exploit_declaration.committee_id = commitee.id
       AND exploit_declaration.region_id = region.id
       AND exploit_declaration.register_date >= '"$date_before"'
       AND exploit_declaration.register_date < '"$date_after"'
  )
  TO '/tmp/заявки_эксплуатацию.csv'
  WITH (FORMAT CSV, HEADER TRUE, FORCE_QUOTE *)"

req_eks_isp="\\copy (
  SELECT commitee.name
    AS \"Исполком\", COUNT(commitee.name)
    AS \"Кол-во\",
    CASE WHEN exploit_declaration.archive
      THEN 'Да' ELSE 'Нет' END
    AS \"Помещено в архив\"
    FROM public.exploit_declaration, public.commitee
    WHERE exploit_declaration.committee_id = commitee.id
    AND exploit_declaration.register_date >= '"$date_before"'
    AND exploit_declaration.register_date < '"$date_after"'
    GROUP BY commitee.name, exploit_declaration.archive
    ORDER BY commitee.name
  )
  TO '/tmp/заявки_эксплуатацию_исполкомы.csv'
  WITH (FORMAT CSV, HEADER TRUE, FORCE_QUOTE *)"

req_proj="\\copy (
  SELECT project_declaration.id, commitee.name
    AS \"Исполком\", region.name
    AS \"Область\", project_declaration.object_number
    AS \"Номер\", project_declaration.object_name
    AS \"Наименование\", object_status.text
    AS \"Состояние\", project_declaration.create_date
    AS \"Создано\", project_declaration.register_date
    AS \"Отправлено в НЦОТ\", project_declaration.modify_date
    AS \"Последнее изменение\",
    CASE WHEN project_declaration.archive = TRUE
      THEN 'Да' ELSE 'Нет' END
    AS \"В архиве\"
    FROM public.project_declaration, public.commitee, public.object_status, public.region
    WHERE project_declaration.committee_id = commitee.id
    AND project_declaration.declaration_status = object_status.id
    AND project_declaration.region_id = region.id
    AND project_declaration.register_date >= '"$date_before"'
    AND project_declaration.register_date < '"$date_after"'
  )
  TO '/tmp/заявки_проектирование.csv'
  WITH (FORMAT CSV, HEADER TRUE, FORCE_QUOTE *)"

req_proj_isp="\\copy (
  SELECT commitee.name
    AS \"Исполком\",
    COUNT(commitee.name)
    AS \"Кол-во\",
    CASE WHEN project_declaration.archive
      THEN 'Да' ELSE 'Нет' END
    AS \"Помещено в архив\"
    FROM public.project_declaration, public.commitee
    WHERE project_declaration.committee_id = commitee.id
    AND project_declaration.register_date >= '"$date_before"'
    AND project_declaration.register_date < '"$date_after"'
    GROUP BY commitee.name, project_declaration.archive
    ORDER BY commitee.name
  )
  TO '/tmp/заявки_проктирование_исполкомы.csv'
  WITH (FORMAT CSV, HEADER TRUE, FORCE_QUOTE *)"

# Connect to server
ssh fcdb@10.72.143.250 -f -N -L 5432:127.0.0.1:5432
#PID=$!

# Run SQL-requests
psql -h 127.0.0.1 -p 5432 -U postgres vols -c "$req_eks"
psql -h 127.0.0.1 -p 5432 -U postgres vols -c "$req_eks_isp"
psql -h 127.0.0.1 -p 5432 -U postgres vols -c "$req_proj"
psql -h 127.0.0.1 -p 5432 -U postgres vols -c "$req_proj_isp"

# Cleanup
#lsof -ti:5432
#kill -9 $PID
kill -9 `lsof -ti:5432`
