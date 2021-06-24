/**
  Group sessions with a vector object for events.
 */
 with
  e as (
    select session_id_hash,
    organization_id,
    array_agg(event) within group (order by server_timestamp asc) as events
    from
    (select object_construct(
          'event_type',event_type,
          'product_action',product_action,
          'product_sku_hash',product_sku_hash,
          'hashed_url', hashed_url,
          'server_timestamp', server_timestamp
        ) as event,
        server_timestamp,
        session_id_hash,
        organization_id
        from {{ ref('distinct_events') }})
    group by session_id_hash, organization_id
    ),
  s as (
    select session_id_hash, start_time, session_action_count
    from {{ ref('session_stats') }}
  )
select *
from e inner join s using(session_id_hash) order by start_time asc