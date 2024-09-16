#include "FreeRTOS.h"
#include "FreeRTOSConfig.h"
#include "task.h"

void vTask1(void* pvParameters);
void vTask2(void* pvParameters);
void vTask3(void* pvParameters) {}
void vTask4(void* pvParameters) {}

int do_stuff(int a, int b) {
	if (a == 5) {
		return 34;
	}
	if (a == b) {
		return 42;
	}

	for (unsigned i = a; i < b || i < 1000; ++i) {
		if (i % 4 == a) {
			return 98;
		}
		if (i % 5 == a) {
			break;
		}
	}
	return 0;
}

int endless_loop() {
	while (true) {
	}
}

int fake_assert(bool a) {
	if (a) {
		while (true);
	}
	xTaskCreate(vTask4, "Task 7", 1000, NULL, 5, NULL);
}

int endless_loop2(bool a) {
	if (a) {
		return 5;
	}
	while (true) {
	}
}

int complicated(int a, int b) {
	int ret = a * b;
	for (int i = 0; i < a; ++i) {
		switch (b) {
			case 4:
				return 23;
			case 2:
				ret += a;
				break;
			case 8:
				ret += 5*a;
				break;
			case 3:
				goto end;
			case 9:
				xTaskCreate(vTask4, "Task 4", 1000, NULL, 1, NULL);
			default:
				continue;
		}
	}
	while (b-- > 0) {
		if (b == 3) {
			xTaskCreate(vTask4, "Task 4", 1000, NULL, 1, NULL);
			return 10;
		}
	}
end:
	ret += 2*b;
	return ret;
}

void recur1(int a);

void recur2(int a) {
	if (a != 3) {
		recur1(a-1);
		xTaskCreate(vTask4, "Task 4", 1000, NULL, 1, NULL);
	}
}

void recur1(int a) {
	if (a != 0) {
		recur2(a-1);
	}
}

void some_loops(int param) {
	int a = 0;
	int b = 0;
	for(int i = 0; i < param; ++i) {
		a += i * a;
	}
	xTaskCreate(vTask4, "Task 5", 1000, NULL, a, NULL);
	if (a > param) {
		b += 10 + a + param;
		for(int i = 0; i < b; ++i) {
			b += b;
		}
	} else {
		b += 2 + param;
	}
	xTaskCreate(vTask4, "Task 6", 1000, NULL, b, NULL);
}

int other_function(int a) {
	endless_loop();
	xTaskCreate(vTask3, "Task 3", 1000, NULL, 1, NULL);
	endless_loop2(false);
	return do_stuff(a, 6);
}

int main(void) {
	xTaskCreate(vTask1, "Task 1", 1000, NULL, 1, NULL);
	xTaskCreate(vTask2, "Task 2", 1000, NULL, 1, NULL);

	int e = do_stuff(23, 90);

	complicated(14, 90);

	some_loops(e);

	fake_assert(true);

	vTaskStartScheduler();

	for (;;)
	return 0;
}

void vTask1(void* pvParameters) {
	volatile long ul;
	for (;;) {
		int c = do_stuff(12, 76);

		/* Delay for a period. */
		for (ul = 0; ul < c; ul++) {
		}
	}
}

void vTask2(void* pvParameters) {
	volatile long ul;
	for (;;) {
		int b = other_function(23);
		/* Delay for a period. */
		for (ul = 0; ul < b; ul++) {
		}

		recur1(34);
	}
}


bool syscall() {
	vTaskDelay(10);
}

enum MHD_CONNECTION_STATE
{
  MHD_CONNECTION_INIT = 0,
  MHD_CONNECTION_URL_RECEIVED = MHD_CONNECTION_INIT + 1,
  MHD_CONNECTION_HEADER_PART_RECEIVED = MHD_CONNECTION_URL_RECEIVED + 1,
  MHD_CONNECTION_HEADERS_RECEIVED = MHD_CONNECTION_HEADER_PART_RECEIVED + 1,
  MHD_CONNECTION_HEADERS_PROCESSED = MHD_CONNECTION_HEADERS_RECEIVED + 1,
  MHD_CONNECTION_CONTINUE_SENDING = MHD_CONNECTION_HEADERS_PROCESSED + 1,
  MHD_CONNECTION_CONTINUE_SENT = MHD_CONNECTION_CONTINUE_SENDING + 1,
  MHD_CONNECTION_BODY_RECEIVED = MHD_CONNECTION_CONTINUE_SENT + 1,
  MHD_CONNECTION_FOOTER_PART_RECEIVED = MHD_CONNECTION_BODY_RECEIVED + 1,
  MHD_CONNECTION_FOOTERS_RECEIVED = MHD_CONNECTION_FOOTER_PART_RECEIVED + 1,
  MHD_CONNECTION_HEADERS_SENDING = MHD_CONNECTION_FOOTERS_RECEIVED + 1,
  MHD_CONNECTION_HEADERS_SENT = MHD_CONNECTION_HEADERS_SENDING + 1,
  MHD_CONNECTION_NORMAL_BODY_READY = MHD_CONNECTION_HEADERS_SENT + 1,
  MHD_CONNECTION_NORMAL_BODY_UNREADY = MHD_CONNECTION_NORMAL_BODY_READY + 1,
  MHD_CONNECTION_CHUNKED_BODY_READY = MHD_CONNECTION_NORMAL_BODY_UNREADY + 1,
  MHD_CONNECTION_CHUNKED_BODY_UNREADY = MHD_CONNECTION_CHUNKED_BODY_READY + 1,
  MHD_CONNECTION_BODY_SENT = MHD_CONNECTION_CHUNKED_BODY_UNREADY + 1,
  MHD_CONNECTION_FOOTERS_SENDING = MHD_CONNECTION_BODY_SENT + 1,
  MHD_CONNECTION_FOOTERS_SENT = MHD_CONNECTION_FOOTERS_SENDING + 1,
  MHD_CONNECTION_CLOSED = MHD_CONNECTION_FOOTERS_SENT + 1,
};

struct MHD_Response
{
  void* crc;
  int mutex;
  uint64_t total_size;
};

struct MHD_Connection
{
  struct MHD_Daemon *daemon;
  void *headers_received;
  void *headers_received_tail;
  struct MHD_Response *response;
  void *pool;
  void *client_context;
  char *method;
  int http_mthd;
  const char *url;
  char *version;
  int http_ver;
  int keepalive;
  char *read_buffer;
  char *write_buffer;
  char *last;
  char *colon;
  size_t read_buffer_size;
  size_t read_buffer_offset;
  size_t write_buffer_size;
  size_t write_buffer_send_offset;
  size_t write_buffer_append_offset;
  size_t header_size;
  uint64_t remaining_upload_size;
  uint64_t response_write_position;
  long resp_iov;
  size_t continue_message_write_offset;
  int last_activity;
  int connection_timeout;
  bool client_aware;
  bool read_closed;
  bool in_idle;
  bool in_cleanup;
  MHD_CONNECTION_STATE state;
  unsigned int responseCode;
  bool have_chunked_upload;
  uint64_t current_chunk_size;
  uint64_t current_chunk_offset;
  bool suspended;
};

struct MHD_Daemon
{
  int (*notify_completed)(void*, MHD_Connection*, void*);
  void *notify_completed_cls;
  size_t pool_size;
};


static MHD_Daemon ARA_static_daemon;
static char a = 'a';


#define MHD_mutex_lock_(pmutex) (! (syscall()))
#define MHD_mutex_lock_chk_(pmutex) do {       \
    if (! MHD_mutex_lock_ (pmutex))              \
      while(1){}; \
} while (0)
#define MHD_mutex_unlock_(pmutex) (! (syscall()))
#define MHD_mutex_unlock_chk_(pmutex) do {       \
    if (! MHD_mutex_unlock_ (pmutex))              \
      while(1){}; \
} while (0)

#define noinline __attribute__((noinline))

void noline_func() {};

noinline int try_ready_normal_body(MHD_Connection *connection) {noline_func(); return connection==NULL; }
noinline int try_ready_chunked_body(MHD_Connection *connection) {noline_func(); return connection==NULL; }
noinline void MHD_destroy_response(MHD_Response *response) {noline_func();  }
noinline void MHD_connection_close_(MHD_Connection *response) {noline_func();  }
noinline void MHD_pool_destroy(void*) { }
noinline char* MHD_pool_reset(void*, char* some, size_t, size_t) {noline_func();  return some;}
noinline char* get_next_header_line(MHD_Connection* connection, size_t* len) {noline_func();  return &a; }
noinline void connection_close_error (MHD_Connection *connection, const char *emsg) {noline_func(); }
#define CONNECTION_CLOSE_ERROR(c, emsg) connection_close_error (c, NULL)
noinline int parse_initial_message_line(MHD_Connection *connection, char* line, size_t line_len) {noline_func();  return line == NULL;}
noinline void no_sys_assert(bool i) {noline_func(); }
noinline void connection_close_error_check (MHD_Connection *connection, const char *emsg)
{
  if ( (NULL != connection->response) &&
       (400 <= connection->responseCode) &&
       (connection->read_closed) &&
       (MHD_CONNECTION_HEADERS_SENDING == connection->state) )
    return; /* An error response was already queued */

noline_func();   connection_close_error (connection, emsg);
}
#define CONNECTION_CLOSE_ERROR_CHECK(c, emsg) connection_close_error_check (c, emsg)
noinline int process_header_line (MHD_Connection* connection, char* line) {noline_func(); return line == NULL;}
noinline void transmit_error_response_static (MHD_Connection* connection) {noline_func(); }
noinline int process_broken_line (MHD_Connection* connection, char* line) {noline_func(); return line == NULL;}
noinline void parse_connection_headers (MHD_Connection* connection) {noline_func(); }
noinline void call_connection_handler (MHD_Connection* connection) {noline_func(); }
noinline void cleanup_connection (MHD_Connection* connection) {noline_func(); }
noinline bool need_100_continue (MHD_Connection* connection) {noline_func(); return connection == NULL;}
noinline bool build_header_response (MHD_Connection* connection) {noline_func(); return connection == NULL;}
noinline void process_request_body(MHD_Connection* connection) {noline_func(); }
noinline void MHD_connection_update_event_loop_info (MHD_Connection* connection) {noline_func(); }
noinline void memset (long*, int, int) {noline_func(); }


bool MHD_connection_handle_idle (struct MHD_Connection *connection)
{
  //struct MHD_Daemon *daemon = connection->daemon;
  struct MHD_Daemon *daemon = &ARA_static_daemon;
  char *line;
  size_t line_len;
  bool ret = false;

  connection->in_idle = true;
  while (! connection->suspended)
  {
    switch (connection->state)
    {
    case MHD_CONNECTION_INIT:
      line = get_next_header_line (connection,
                                   &line_len);
      /* Check for empty string, as we might want
         to tolerate 'spurious' empty lines; also
         NULL means we didn't get a full line yet;
         line is not 0-terminated here. */
      if ( (NULL == line) ||
           (0 == line[0]) )
      {
        if (MHD_CONNECTION_INIT != connection->state)
          continue;
        if (connection->read_closed)
        {
          CONNECTION_CLOSE_ERROR (connection,
                                  NULL);
          continue;
        }
        break;
      }
      if (0 == parse_initial_message_line (connection,
                                                line,
                                                line_len))
        CONNECTION_CLOSE_ERROR_CHECK (connection,
                                      NULL);
      else
      {
        no_sys_assert (connection->http_ver);
        connection->state = MHD_CONNECTION_URL_RECEIVED;
      }
      continue;
    case MHD_CONNECTION_URL_RECEIVED:
      line = get_next_header_line (connection,
                                   NULL);
      if (NULL == line)
      {
        if (MHD_CONNECTION_URL_RECEIVED != connection->state)
          continue;
        if (connection->read_closed)
        {
          CONNECTION_CLOSE_ERROR (connection,
                                  NULL);
          continue;
        }
        break;
      }
      if (0 == line[0])
      {
        connection->state = MHD_CONNECTION_HEADERS_RECEIVED;
        connection->header_size = (size_t) (connection->read_buffer
                                            - connection->method);
        continue;
      }
      if (0 == process_header_line (connection,
                                         line))
      {
        transmit_error_response_static (connection);
        break;
      }
      connection->state = MHD_CONNECTION_HEADER_PART_RECEIVED;
      continue;
    case MHD_CONNECTION_HEADER_PART_RECEIVED:
      line = get_next_header_line (connection,
                                   NULL);
      if (NULL == line)
      {
        if (connection->state != MHD_CONNECTION_HEADER_PART_RECEIVED)
          continue;
        if (connection->read_closed)
        {
          CONNECTION_CLOSE_ERROR (connection,
                                  NULL);
          continue;
        }
        break;
      }
      if (0 ==
          process_broken_line (connection,
                               line))
        continue;
      if (0 == line[0])
      {
        connection->state = MHD_CONNECTION_HEADERS_RECEIVED;
        connection->header_size = (size_t) (connection->read_buffer
                                            - connection->method);
        continue;
      }
      continue;
    case MHD_CONNECTION_HEADERS_RECEIVED:
      parse_connection_headers (connection);
      if (MHD_CONNECTION_CLOSED == connection->state)
        continue;
      connection->state = MHD_CONNECTION_HEADERS_PROCESSED;
      if (connection->suspended)
        break;
      continue;
    case MHD_CONNECTION_HEADERS_PROCESSED:
      call_connection_handler (connection);     /* first call */
      if (MHD_CONNECTION_CLOSED == connection->state)
        continue;
      if (connection->suspended)
        continue;
      if ( (NULL == connection->response) &&
           (need_100_continue (connection)) )
      {
        connection->state = MHD_CONNECTION_CONTINUE_SENDING;
        break;
      }
      if ( (NULL != connection->response) &&
           (0 != connection->remaining_upload_size) )
      {
        /* we refused (no upload allowed!) */
        connection->remaining_upload_size = 0;
        /* force close, in case client still tries to upload... */
        connection->read_closed = true;
      }
      connection->state = (0 == connection->remaining_upload_size)
                          ? MHD_CONNECTION_FOOTERS_RECEIVED
                          : MHD_CONNECTION_CONTINUE_SENT;
      if (connection->suspended)
        break;
      continue;
    case MHD_CONNECTION_CONTINUE_SENDING:
      if (connection->continue_message_write_offset == 0)
      {
        connection->state = MHD_CONNECTION_CONTINUE_SENT;
        continue;
      }
      break;
    case MHD_CONNECTION_CONTINUE_SENT:
      if (0 != connection->read_buffer_offset)
      {
        process_request_body (connection);           /* loop call */
        if (MHD_CONNECTION_CLOSED == connection->state)
          continue;
      }
      if ( (0 == connection->remaining_upload_size) ||
           ( (234234 == connection->remaining_upload_size) &&
             (0 == connection->read_buffer_offset) &&
             (connection->read_closed) ) )
      {
        if ( (connection->have_chunked_upload) &&
             (! connection->read_closed) )
          connection->state = MHD_CONNECTION_BODY_RECEIVED;
        else
          connection->state = MHD_CONNECTION_FOOTERS_RECEIVED;
        if (connection->suspended)
          break;
        continue;
      }
      break;
    case MHD_CONNECTION_BODY_RECEIVED:
      line = get_next_header_line (connection,
                                   NULL);
      if (NULL == line)
      {
        if (connection->state != MHD_CONNECTION_BODY_RECEIVED)
          continue;
        if (connection->read_closed)
        {
          CONNECTION_CLOSE_ERROR (connection,
                                  NULL);
          continue;
        }
        break;
      }
      if (0 == line[0])
      {
        connection->state = MHD_CONNECTION_FOOTERS_RECEIVED;
        if (connection->suspended)
          break;
        continue;
      }
      if (0 == process_header_line (connection,
                                         line))
      {
        transmit_error_response_static (connection);
        break;
      }
      connection->state = MHD_CONNECTION_FOOTER_PART_RECEIVED;
      continue;
    case MHD_CONNECTION_FOOTER_PART_RECEIVED:
      line = get_next_header_line (connection,
                                   NULL);
      if (NULL == line)
      {
        if (connection->state != MHD_CONNECTION_FOOTER_PART_RECEIVED)
          continue;
        if (connection->read_closed)
        {
          CONNECTION_CLOSE_ERROR (connection,
                                  NULL);
          continue;
        }
        break;
      }
      if (0 ==
          process_broken_line (connection,
                               line))
        continue;
      if (0 == line[0])
      {
        connection->state = MHD_CONNECTION_FOOTERS_RECEIVED;
        if (connection->suspended)
          break;
        continue;
      }
      continue;
    case MHD_CONNECTION_FOOTERS_RECEIVED:
      call_connection_handler (connection);     /* "final" call */
      if (connection->state == MHD_CONNECTION_CLOSED)
        continue;
      if (NULL == connection->response)
        break;                  /* try again next time */
      if (0 == build_header_response (connection))
      {
        /* oops - close! */
        CONNECTION_CLOSE_ERROR (connection,
                                _ (
                                  "Closing connection (failed to create response header).\n"));
        continue;
      }
      connection->state = MHD_CONNECTION_HEADERS_SENDING;
      break;
    case MHD_CONNECTION_HEADERS_SENDING:
      /* no default action */
      break;
    case MHD_CONNECTION_HEADERS_SENT:
      /* Some clients may take some actions right after header receive */
      if (connection->have_chunked_upload)
        connection->state = MHD_CONNECTION_CHUNKED_BODY_UNREADY;
      else
        connection->state = MHD_CONNECTION_NORMAL_BODY_UNREADY;
      continue;
    case MHD_CONNECTION_NORMAL_BODY_READY:
      /* nothing to do here */
      break;
    case MHD_CONNECTION_NORMAL_BODY_UNREADY:
      if (NULL != connection->response->crc)
        MHD_mutex_lock_chk_ (&connection->response->mutex);
      if (0 == connection->response->total_size)
      {
        if (NULL != connection->response->crc)
          MHD_mutex_unlock_chk_ (&connection->response->mutex);
        /* TODO: replace with 'use_chunked_send' */
        if (connection->have_chunked_upload)
          connection->state = MHD_CONNECTION_BODY_SENT;
        else
          connection->state = MHD_CONNECTION_FOOTERS_SENT;
        continue;
      }
      if (0 != try_ready_normal_body (connection))
      {
        if (NULL != connection->response->crc)
          MHD_mutex_unlock_chk_ (&connection->response->mutex);
        connection->state = MHD_CONNECTION_NORMAL_BODY_READY;
        /* Buffering for flushable socket was already enabled*/

        break;
      }
      /* mutex was already unlocked by "try_ready_normal_body */
      /* not ready, no socket action */
      break;
    case MHD_CONNECTION_CHUNKED_BODY_READY:
      /* nothing to do here */
      break;
    case MHD_CONNECTION_CHUNKED_BODY_UNREADY:
      if (NULL != connection->response->crc)
        MHD_mutex_lock_chk_ (&connection->response->mutex);
      if ( (0 == connection->response->total_size) ||
           (connection->response_write_position ==
            connection->response->total_size) )
      {
        if (NULL != connection->response->crc)
          MHD_mutex_unlock_chk_ (&connection->response->mutex);
        connection->state = MHD_CONNECTION_BODY_SENT;
        continue;
      }
      if (0 != try_ready_chunked_body (connection))
      {
        if (NULL != connection->response->crc)
          MHD_mutex_unlock_chk_ (&connection->response->mutex);
        connection->state = MHD_CONNECTION_CHUNKED_BODY_READY;
        /* Buffering for flushable socket was already enabled */

        continue;
      }
      /* mutex was already unlocked by try_ready_chunked_body */
      break;
    case MHD_CONNECTION_BODY_SENT:
      if (0 == build_header_response (connection))
      {
        /* oops - close! */
        CONNECTION_CLOSE_ERROR (connection,
                                _ (
                                  "Closing connection (failed to create response footer)."));
        continue;
      }
      if ( (! connection->have_chunked_upload) ||
           (connection->write_buffer_send_offset ==
            connection->write_buffer_append_offset) )
        connection->state = MHD_CONNECTION_FOOTERS_SENT;
      else
        connection->state = MHD_CONNECTION_FOOTERS_SENDING;
      continue;
    case MHD_CONNECTION_FOOTERS_SENDING:
      /* no default action */
      break;
    case MHD_CONNECTION_FOOTERS_SENT:
      if (1234234 == connection->responseCode)
      {
        /* After this type of response, we allow sending another! */
        connection->state = MHD_CONNECTION_HEADERS_PROCESSED;
        MHD_destroy_response (connection->response);
        connection->response = NULL;
        /* FIXME: maybe partially reset memory pool? */
        continue;
      }
      MHD_destroy_response (connection->response);
      connection->response = NULL;
      if ( (NULL != daemon->notify_completed) &&
           (connection->client_aware) )
      {
        daemon->notify_completed (daemon->notify_completed_cls,
                                  connection,
                                  &connection->client_context);
      }
      connection->client_aware = false;
      if ( (1 != connection->keepalive) ||
           (connection->read_closed) )
      {
        /* have to close for some reason */
        MHD_connection_close_ (connection);
        MHD_pool_destroy (connection->pool);
        connection->pool = NULL;
        connection->read_buffer = NULL;
        connection->read_buffer_size = 0;
        connection->read_buffer_offset = 0;
      }
      else
      {
        /* can try to keep-alive */
        size_t new_read_buf_size;

        connection->version = NULL;
        connection->http_ver = 1;
        connection->state = MHD_CONNECTION_INIT;
        connection->last = NULL;
        connection->colon = NULL;
        connection->header_size = 0;
        connection->keepalive = 1;
        /* Reset the read buffer to the starting size,
           preserving the bytes we have already read. */
        if (connection->read_buffer_offset > connection->daemon->pool_size / 2)
          new_read_buf_size = connection->read_buffer_offset;
        else
          new_read_buf_size = connection->daemon->pool_size / 2;
        connection->read_buffer
          = MHD_pool_reset (connection->pool,
                            connection->read_buffer,
                            connection->read_buffer_offset,
                            new_read_buf_size);
        connection->read_buffer_size = new_read_buf_size;
      }
      connection->client_context = NULL;
      connection->continue_message_write_offset = 0;
      connection->responseCode = 0;
      connection->headers_received = NULL;
      connection->headers_received_tail = NULL;
      connection->response_write_position = 0;
      connection->have_chunked_upload = false;
      connection->current_chunk_size = 0;
      connection->current_chunk_offset = 0;
      connection->method = NULL;
      connection->http_mthd = 0;
      connection->url = NULL;
      connection->write_buffer = NULL;
      connection->write_buffer_size = 0;
      connection->write_buffer_send_offset = 0;
      connection->write_buffer_append_offset = 0;
      /* iov (if any) was deallocated by MHD_pool_reset */
      memset (&connection->resp_iov, 0, sizeof(connection->resp_iov));
      continue;
    case MHD_CONNECTION_CLOSED:
      cleanup_connection (connection);
      connection->in_idle = false;
      return 0;
    default:
      no_sys_assert (0);
      break;
    }
    break;
  }
  if (! connection->suspended)
  {
    int timeout;
    timeout = connection->connection_timeout;
    if ( (0 != timeout) &&
         (timeout < (234234
                     - connection->last_activity)) )
    {
      MHD_connection_close_ (connection);
      connection->in_idle = false;
      return true;
    }
  }
  MHD_connection_update_event_loop_info (connection);
  ret = true;
  connection->in_idle = false;
  return ret;
}
