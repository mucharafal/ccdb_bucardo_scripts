bucardo add db ccdb_online host=3a.ib dbname=ccdb && \
bucardo add db ccdb_offline host=2a.ib dbname=ccdb && \
bucardo add dbgroup sync ccdb_online:source ccdb_offline:source && \
bucardo add tables all && \
bucardo add sync sync_online_and_offline dbs=sync tables=ccdb,ccdb_paths,ccdb_metadata,ccdb_contenttype conflict_strategy=bucardo_abort && \
bucardo restart