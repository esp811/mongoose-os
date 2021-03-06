/*
 * Copyright (c) 2014-2016 Cesanta Software Limited
 * All rights reserved
 */

#ifndef CS_FW_SRC_MGOS_MQTT_GLOBAL_H_
#define CS_FW_SRC_MGOS_MQTT_GLOBAL_H_

#include "fw/src/mgos_init.h"
#include "fw/src/mgos_mongoose.h"

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#if MGOS_ENABLE_MQTT

/* Initialises global MQTT connection */
enum mgos_init_result mgos_mqtt_global_init(void);

/*
 * Subscribe to a specific topic.
 * This handler will receive SUBACK - when first subscribed to the topic,
 * PUBLISH - for messages published to this topic, PUBACK - acks for PUBLISH
 * requests. MG_EV_CLOSE - when connection is closed.
 */
void mgos_mqtt_global_subscribe(const struct mg_str topic,
                                mg_event_handler_t handler, void *ud);

/* Registers a mongoose handler to be invoked on the global MQTT connection */
void mgos_mqtt_set_global_handler(mg_event_handler_t handler, void *ud);

/*
 * Returns current MQTT connection if it is established; otherwise returns
 * `NULL`
 */
struct mg_connection *mgos_mqtt_get_global_conn(void);

#endif /* MGOS_ENABLE_MQTT */

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* CS_FW_SRC_MGOS_MQTT_GLOBAL_H_ */
