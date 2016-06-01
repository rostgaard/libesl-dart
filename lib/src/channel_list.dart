// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

part of esl;

/**
 * Channel list. Can be used to keep track of channels in the FreeSWITCH PBX by
 * using the [update] method as event handler for CHANNEL_STATE and others,
 * depending on the level of detail in the channel information you wish.
 */
class ChannelList extends IterableBase<Channel> {
  Map<String, Channel> _channelStorage = new Map<String, Channel>();

  Iterator<Channel> get iterator => this._channelStorage.values.iterator;

  /**
   * Replace the channels in the [ChannelList] with [channels].
   */
  void reload(Iterable<Channel> channels) {
    this._channelStorage.clear();
    channels.forEach((Channel channel) {
      this._channelStorage[channel.UUID] = channel;
    });
  }

  /**
   * Updates a channel stored in the channel list. Removes it, if it is
   * destroyed, adds it when it is created and merely updates the information
   * associated with channel (variables and fields) with the new information.
   */
  void update(Channel channel) {
    if (!this._channelStorage.containsKey(channel.UUID)) {
      this._add(channel);
    } else {
      Channel oldChannel = this._channelStorage[channel.UUID];

      if (channel.variables.isEmpty) {
        this._channelStorage[channel.UUID] =
            new Channel.assemble(channel.fields, oldChannel.variables);
      } else {
        this._channelStorage[channel.UUID] = channel;
      }
    }

    if (channel.state == ChannelState.DESTROY) {
      this._remove(channel);
    }
  }

  void _add(Channel channel) {
    this._channelStorage[channel.UUID] = channel;
  }

  /**
   * Retrieve a single channel identified by [channelID]. Returns [null] if no
   * channel is found in the list.
   */
  Channel get(String channelID) => this._channelStorage[channelID];

  void _remove(Channel channel) {
    this._channelStorage.remove(channel.UUID);
  }
}
