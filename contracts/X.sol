// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

contract X {
    struct Post {
        address author;
        string content;
        uint256 timestamp;
        uint256 likes;
    }

    uint16 constant MAX_POST_LENGTH = 280;

    uint256 postCount = 0;
    address[] public users;
    mapping(address => Post[]) public posts;

    function post(string memory _content) public {
        require(bytes(_content).length < MAX_POST_LENGTH, "Post content length can't surpass 280 characters.");

        Post memory newPost = Post({
            author: msg.sender,
            content: _content,
            timestamp: block.timestamp,
            likes: 0
        });

        posts[msg.sender].push(newPost);
        registerUser(msg.sender);
    }

    function registerUser(address _user) private {
        for (uint256 i = 0; i < users.length; i++) {
            if (users[i] == _user) return;
        }
        users.push(_user);
    }

    function getPost(address _user, uint256 _id) public view returns (Post memory) {
        require(_id < posts[_user].length, "Couldn't find the requested post.");
        return posts[_user][_id];
    }

    function getPostCount() private {
        for (uint256 i = 0; i < users.length; i++) {
            postCount += posts[users[i]].length;
        }
    }

    function getAllPosts() public returns (Post[] memory) {
        getPostCount();

        Post[] memory result = new Post[](postCount);

        uint256 counter = 0;

        for (uint256 i = 0; i < users.length; i++) {
            for (uint256 j = 0; j < posts[users[i]].length; j++) {
                result[counter] = posts[users[i]][j];
                counter++;
            }
        }

        return result;
    }
}
