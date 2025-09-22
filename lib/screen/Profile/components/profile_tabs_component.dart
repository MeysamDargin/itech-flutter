import 'package:flutter/material.dart';

class ProfileTabsComponent extends StatefulWidget {
  final List<String> tabs;
  final int selectedTabIndex;
  final Function(int) onTabSelected;

  const ProfileTabsComponent({
    Key? key,
    required this.tabs,
    required this.selectedTabIndex,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  State<ProfileTabsComponent> createState() => _ProfileTabsComponentState();
}

class _ProfileTabsComponentState extends State<ProfileTabsComponent> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.background,
        // border: Border(
        //   top: BorderSide(color: Color(0xffF8F8F8), width: 2),
        //   bottom: BorderSide(color: Color(0xffF8F8F8), width: 8),
        // ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.tabs.length, (index) {
                bool isSelected = widget.selectedTabIndex == index;
                return Container(
                  width: 100,
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child: GestureDetector(
                    onTap: () {
                      widget.onTabSelected(index);
                    },
                    child: Container(
                      child: Row(
                        children: [
                          // Tab icon
                          Image(
                            image:
                                index == 0
                                    ? AssetImage(
                                      "assets/icons/grid-svgrepo-com.png",
                                    )
                                    : AssetImage(
                                      "assets/icons/user-id-svgrepo-com.png",
                                    ),
                            color: isSelected ? Color(0xFF3E48DF) : Colors.grey,
                            width: 28,
                            height: 28,
                          ),
                          const SizedBox(width: 4),
                          // Tab text
                          Text(
                            widget.tabs[index],
                            style: TextStyle(
                              color:
                                  isSelected ? Color(0xFF3E48DF) : Colors.grey,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                              fontSize: 16,
                              fontFamily: "a-m",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Spacer(flex: 2),
          // Settings icon on the right
          Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(right: 10),
            child: Image(
              image: AssetImage("assets/icons/setting-4-svgrepo-com.png"),
              color: Colors.grey,
              width: 24,
              height: 24,
            ),
          ),
        ],
      ),
    );
  }
}
