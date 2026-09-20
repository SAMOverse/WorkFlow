-- WorkFlow draft schema -- see docs/PROJECT_SPEC.md §5 for the rationale.
-- Not yet applied to a real Supabase project. Apply via the Supabase SQL
-- editor or `supabase db push` once a project exists, then refine as real
-- use surfaces gaps -- this is a starting point, not a final design.

create table projects (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid references auth.users not null,
  name text not null,
  start_date date,
  end_date date,
  created_at timestamptz default now()
);

create table resources (
  id uuid primary key default gen_random_uuid(),
  project_id uuid references projects not null,
  name text not null,
  capacity numeric default 1.0,  -- 1.0 = fully available per day
  created_at timestamptz default now()
);

create table tasks (
  id uuid primary key default gen_random_uuid(),
  project_id uuid references projects not null,
  parent_task_id uuid references tasks,  -- simple one-level grouping
  name text not null,
  start_date date not null,
  end_date date not null,
  percent_complete numeric default 0,
  is_milestone boolean default false,
  notes text,
  created_at timestamptz default now()
);

create table task_assignments (
  task_id uuid references tasks not null,
  resource_id uuid references resources not null,
  primary key (task_id, resource_id)
);

create table task_dependencies (
  predecessor_task_id uuid references tasks not null,
  successor_task_id uuid references tasks not null,
  -- v1: finish-to-start only, so no dependency_type column yet -- add
  -- it later (SS/FF/SF) rather than modeling unused flexibility now
  primary key (predecessor_task_id, successor_task_id)
);

-- Row-Level Security: every table scoped to the owning user via projects.owner_id.
-- Enable and write real policies once auth is wired up -- left off here
-- deliberately rather than writing untested policies against no real usage.
alter table projects enable row level security;
alter table resources enable row level security;
alter table tasks enable row level security;
alter table task_assignments enable row level security;
alter table task_dependencies enable row level security;
