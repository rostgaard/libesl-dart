part of esl;

class ChannelList extends IterableBase<Channel> {

  Map<String,Channel> _channelStorage = new Map<String,Channel>();

  Iterator<Channel> get iterator => this._channelStorage.values.iterator;

  void update(Channel channel) {
    if (!this._channelStorage.containsKey(channel.UUID)) {
      this._add (channel);
    } else {
      Channel oldChannel = this._channelStorage[channel.UUID];

      if (channel.variables.isEmpty) {
        this._channelStorage[channel.UUID] = new Channel.assemble(channel.fields, oldChannel.variables);
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

  Channel get(String channelID) =>
    this._channelStorage[channelID];


  void _remove(Channel channel) {
    this._channelStorage.remove(channel.UUID);
  }
}


