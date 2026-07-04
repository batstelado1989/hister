## Structure

`app/` contains all the resources required to build the hister web UI
`components/` contains all the reusable components used by either the `app/`

## Build

execute `./manage.sh build` to build the `app/`

## Add new component from ShadCN

```bash
cd components
npx shadcn-svelte@latest add [component]
```

change imports from `$lib/utils` to `@hister/components/utils` under `src/lib/components/ui/[component]/*` if necessary
