// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

contract TheBox {

    uint256 internal constant BOX_ITEMS = 1;

    struct Item {
        uint prev;
        uint next;
        bool forSale;
    }

    mapping(uint => Item) internal items;

    uint256 internal itemsCount;
    uint256 internal maxItems;

    uint256 internal head;
    uint256 internal tail;

    constructor(uint256 _maxItems) {
        items[BOX_ITEMS] = Item(BOX_ITEMS, BOX_ITEMS, false);
        head = BOX_ITEMS;
        tail = BOX_ITEMS;
        maxItems = _maxItems;
    }

    error InvalidItemId();
    error NoDuplicates();

    function add(uint _itemId) external {
        if (_itemId == 0 || _itemId == BOX_ITEMS) revert InvalidItemId();
        if (items[_itemId].next != 0) revert NoDuplicates();

        if (itemsCount == maxItems) {
            uint lastItem = tail;

            tail = items[tail].prev;
            items[tail].next = BOX_ITEMS;

            delete items[lastItem];

            itemsCount--;
        }

        items[_itemId] = Item(BOX_ITEMS, head, false);
        items[head].prev = _itemId;
        head = _itemId;

        if (itemsCount == 0) {
            tail = _itemId;
        }

        itemsCount++;
    }

    function contains(uint _itemId) public view returns (bool) {
        return !(_itemId == BOX_ITEMS || items[_itemId].next == 0 && _itemId != head);
    }

    function setFlag(uint _itemId, bool _flag) public {
        if (_itemId == 0 || _itemId == BOX_ITEMS || items[_itemId].next == 0) revert InvalidItemId();
        
        items[_itemId].forSale = _flag;

        if (_itemId != head) {
            uint prevItem = items[_itemId].prev;
            uint nextItem = items[_itemId].next;

            if (_itemId == tail) {
                tail = prevItem;
            } else {
                items[nextItem].prev = prevItem;
            }

            items[prevItem].next = nextItem;

            items[_itemId] = Item(BOX_ITEMS, head, _flag);
            items[head].prev = _itemId;
            head = _itemId;
        }
    }

     function remove(uint _itemId) external {
        if (_itemId == 0 || _itemId == BOX_ITEMS) revert InvalidItemId();
        if (items[_itemId].next == 0 && items[_itemId].prev == 0) revert InvalidItemId();

        uint prevItem = items[_itemId].prev;
        uint nextItem = items[_itemId].next;

        if (_itemId == head) {
            head = nextItem;
        }

        if (_itemId == tail) {
            tail = prevItem;
        }

        items[prevItem].next = nextItem;
        if (nextItem != BOX_ITEMS) {
            items[nextItem].prev = prevItem;
        }

        delete items[_itemId];

        itemsCount--;
    }


    function getAll() external view returns (uint[] memory) {
        uint[] memory result = new uint[](itemsCount);
        uint256 index = 0;

        uint currentItem = head;

        while (currentItem != BOX_ITEMS) {
            result[index] = currentItem;
            currentItem = items[currentItem].next;
            index++;
        }

        return result;
    }
}
