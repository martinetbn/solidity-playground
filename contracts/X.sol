// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

contract X {
    struct Post {
        address author;
        string content;
        uint256 timestamp;
        uint256 likes;
    }

    struct LikedPost{
        address author;
        uint256 id;
    }

    uint16 constant MAX_POST_LENGTH = 280;

    uint256 postCount = 0;
    address[] public users;
    mapping(address => Post[]) public posts;
    mapping(address => LikedPost[]) public likedPosts;

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

    modifier isPostValid(address _user, uint256 _id) {
        require(_id < posts[_user].length, "Couldn't find the requested post.");
        _;
    }

    function getPost(address _user, uint256 _id) public isPostValid(_user, _id) view returns (Post memory) {
        return posts[_user][_id];
    }

    modifier getPostCount() {
        for (uint256 i = 0; i < users.length; i++) {
            postCount += posts[users[i]].length;
        }
        _;
    }

    function getAllPosts() public getPostCount() returns (Post[] memory) {
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

    function likePost(address _user, uint256 _id) public isPostValid(_user, _id) {
        for(uint256 i = 0; i < likedPosts[msg.sender].length; i++){
            require(likedPosts[msg.sender][i].author != _user && likedPosts[msg.sender][i].id != _id, "You have already liked this post.");
        }

        likedPosts[msg.sender].push(LikedPost(_user, _id));
        posts[_user][_id].likes++;
    }
}
