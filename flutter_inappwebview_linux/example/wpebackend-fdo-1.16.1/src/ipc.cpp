/*
 * Copyright (C) 2019 Igalia S.L.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 * PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "ipc.h"
#include <cstdio>

namespace FdoIPC {

static const size_t messageSize = 2 * sizeof(uint32_t);

std::unique_ptr<Connection> Connection::create(int fd, MessageReceiver* messageReceiver)
{
    GError* error = nullptr;
    auto* socket = g_socket_new_from_fd(fd, &error);
    if (!socket) {
        g_warning("Failed to create socket for fd %d: %s", fd, error->message);
        g_error_free(error);

        return nullptr;
    }

    return std::unique_ptr<Connection>(new Connection(socket, messageReceiver));
}

Connection::Connection(GSocket* socket, MessageReceiver* messageReceiver)
    : m_socket(socket)
    , m_messageReceiver(messageReceiver)
{
    g_socket_set_blocking(m_socket, FALSE);

    if (m_messageReceiver) {
        m_socketSource = g_socket_create_source(m_socket, G_IO_IN, nullptr);
        g_source_set_name(m_socketSource, "WPEBackend-fdo::socket");
        g_source_set_callback(m_socketSource, reinterpret_cast<GSourceFunc>(s_socketCallback), this, nullptr);
        g_source_attach(m_socketSource, g_main_context_get_thread_default());
    }
}

Connection::~Connection()
{
    if (m_socketSource) {
        g_source_destroy(m_socketSource);
        g_source_unref(m_socketSource);
    }
    g_clear_object(&m_socket);
}

void Connection::send(uint32_t messageId, uint32_t messageBody)
{
    GError* error = nullptr;
    uint32_t message[2] = { messageId, messageBody };
    gssize len = g_socket_send(m_socket, reinterpret_cast<gchar*>(message), messageSize, nullptr, &error);
    if (len == -1) {
        if (!g_error_matches(error, G_IO_ERROR, G_IO_ERROR_CONNECTION_CLOSED))
            g_warning("Failed to send message %u to socket: %s", messageId, error->message);
        g_error_free(error);
    }
}

gboolean Connection::s_socketCallback(GSocket* socket, GIOCondition condition, gpointer data)
{
    if (!(condition & G_IO_IN))
        return TRUE;

    GError* error = nullptr;
    uint32_t message[2];
    gssize len = g_socket_receive(socket, reinterpret_cast<gchar*>(message), messageSize, nullptr, &error);
    if (len == -1) {
        if (!g_error_matches(error, G_IO_ERROR, G_IO_ERROR_CONNECTION_CLOSED))
            g_warning("Failed to read message from socket: %s", error->message);
        g_error_free(error);
        return FALSE;
    }

    if (len != messageSize)
        return TRUE;

    static_cast<Connection*>(data)->m_messageReceiver->didReceiveMessage(message[0], message[1]);
    return TRUE;
}

} // namespace FdoIPC
