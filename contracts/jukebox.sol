pragma solidity ^0.8.0;
contract Jukebox {
  uint qLength;

  struct Song {
    uint start;
    uint end;
    string url;
    string coverUrl;
    string title;
    string artist;
    address publisher;
  }

  event SongAdded(uint256 start, uint256 end, string url, string coverUrl, string title, string artist, address publisher);

  event queueUp (uint indexed end, string indexed url, string indexed title);

  mapping(uint=>Song) public queue;

  constructor() public {
    qLength = 0;
  }

  function addSong(string memory url, string memory coverUrl, string memory title, string memory artist, uint duration) public {
    uint depth = getQueueDepth();
    uint startPosition = block.number;
    if (depth != 0) {
        startPosition = queue[qLength - 1].end;
    }

    queue[qLength] = Song(startPosition, startPosition + duration, url, coverUrl, title, artist, msg.sender);

    qLength++;

    emit SongAdded(startPosition, startPosition + duration, url, coverUrl, title, artist, msg.sender);
  }

  function getCurrentSong() public view returns (string memory, string memory, string memory, string memory, address, uint, uint) {
    uint depth = getQueueDepth();
    if (depth == 0) {
        return ("", "", "", "", 0x0000000000000000000000000000000000000000, 0, 0);
    }
    Song memory song = queue[qLength - depth];
    return (song.url, song.coverUrl, song.title, song.artist, song.publisher, song.start, song.end);
  }

  function getNextStartTime() public view returns (uint) {
    if (getQueueDepth() == 0) {
        return block.number;
    }

    return (queue[qLength - 1].start);
  }

  function getQueueDepth() public view returns (uint) {
      uint qDepth = 0;
      for (uint i = qLength; i > 0; i--) {
          if (queue[i - 1].start <= block.number && queue[i - 1].end > block.number) {
              qDepth = qLength - i + 1;
              break;
          }
      }
      return qDepth;
  }

  function getSongAtIndex(uint index) public view returns (string memory, string memory, string memory, string memory, address, uint, uint) {
    Song memory song = queue[index];
    return (song.url, song.coverUrl, song.title, song.artist, song.publisher, song.start, song.end);
  }

  function getQueueLength() public view returns (uint) {
      return qLength;
  }

}
