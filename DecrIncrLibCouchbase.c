#include <libcouchbase/couchbase.h>
#include <stdlib.h>
#include <stdio.h>

int main(void)
{
    struct lcb_create_st create_options;
    lcb_t instance;
    lcb_error_t err;

    memset(&create_options, 0, sizeof(create_options));
    create_options.v.v0.host = "ec2-204-236-172-232.us-west-1.compute.amazonaws.com:8091";
    create_options.v.v0.user = "Administrator";
    create_options.v.v0.passwd = "password";
    create_options.v.v0.bucket = "default";

    err = lcb_create(&instance, &create_options);
    if (err != LCB_SUCCESS) {
        fprintf(stderr, "Failed to create libcouchbase instance: %s\n",
                lcb_strerror(NULL, err));
        return 1;
    }
    else {
        fprintf(stdout, "Successful in creating libCouchbase instance: %s\n");
    }
    if ((err = lcb_connect(instance)) != LCB_SUCCESS) {
        fprintf(stderr, "Failed to initiate connect: %s\n",
                lcb_strerror(NULL, err));
        return 1;
    }
    else {
        fprintf(stdout, "Successful in initializing libCouchbase instance: %s\n");
    }

    /* Run the event loop and wait until we've connected */
    lcb_wait(instance);

    lcb_arithmetic_cmd_t arithmetic;
    memset(&arithmetic, 0, sizeof(arithmetic));
    arithmetic.version = 0;
    arithmetic.v.v0.key = "036";
    arithmetic.v.v0.nkey = sizeof(arithmetic.v.v0.key);
    arithmetic.v.v0.create = 1;
    arithmetic.v.v0.delta = -10;
    arithmetic.v.v0.initial = 036;
    const lcb_arithmetic_cmd_t* const commands[1] = { &arithmetic };
    err = lcb_arithmetic(instance, NULL, 1, commands);
    if (err != LCB_SUCCESS) {
        fprintf(stderr, "Failed to incr %s\n",
            lcb_strerror(NULL, err));
        return 1;
    }
    else {
        fprintf(stdout, "Successful in incrementingthe keys and Values: %s\n");
    }

    lcb_wait(instance);

    lcb_destroy(instance);
    exit(EXIT_SUCCESS);
}
