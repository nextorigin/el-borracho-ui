# el-borracho-ui

Realtime Web UI for Bull job queue that pulls from El Borracho REST+SSE API.
Compatible with touch and mobile.

## Introduction

el-borracho-ui is designed to be an intuitive and powerful client for Bull job queue.  All jobs can be fully managed through the UI, which displays job state, data, progress, and stacktrace for failed jobs.  Waiting/delayed/failed jobs may be promoted/re-queued and any job can be deleted.  Jobs may be filtered by queue, state, id, or job data. el-borracho-ui gives a full overview of the health and state of the queue(s) in a single page.

Realtime and historical statistics (from el-borracho-stats) are visualized through el-borracho-graph, a set of Sidekiq-inspired Rickshaw graphs.

All realtime data is read through Server-Sent-Events by default.

## Installation

### NodeJS

```sh
npm install --save el-borracho-ui
```

## License

MIT