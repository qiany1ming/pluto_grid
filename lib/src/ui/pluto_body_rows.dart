import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'ui.dart';

class PlutoBodyRows extends PlutoStatefulWidget {
  final PlutoGridStateManager stateManager;

  const PlutoBodyRows(
    this.stateManager, {
    super.key,
  });

  @override
  PlutoBodyRowsState createState() => PlutoBodyRowsState();
}

class PlutoBodyRowsState extends PlutoStateWithChange<PlutoBodyRows> {
  List<PlutoColumn> _columns = [];

  List<PlutoRow> _rows = [];

  late final ScrollController _verticalScroll;

  late final ScrollController _horizontalScroll;

  @override
  PlutoGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    _horizontalScroll = stateManager.scroll.horizontal!.addAndGet();

    stateManager.scroll.setBodyRowsHorizontal(_horizontalScroll);

    _verticalScroll = stateManager.scroll.vertical!.addAndGet();

    stateManager.scroll.setBodyRowsVertical(_verticalScroll);

    updateState(PlutoNotifierEventForceUpdate.instance);
  }

  @override
  void dispose() {
    _verticalScroll.dispose();

    _horizontalScroll.dispose();

    super.dispose();
  }

  @override
  void updateState(PlutoNotifierEvent event) {
    forceUpdate();

    _columns = _getColumns();

    _rows = stateManager.refRows;
  }

  List<PlutoColumn> _getColumns() {
    return stateManager.showFrozenColumn == true
        ? stateManager.bodyColumns
        : stateManager.columns;
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onSecondaryTapDown: (details) {
          stateManager.rowMenuController.open(position: details.localPosition);
        },
        child: MenuAnchor(
          consumeOutsideTap: true,
          anchorTapClosesMenu: true,
          controller: stateManager.rowMenuController,
          menuChildren: stateManager.rowRightMenuDelegate?.buildMenuItems(stateManager: stateManager, context: context) ?? [],
          child: SingleChildScrollView(
            controller: _horizontalScroll,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: CustomSingleChildLayout(
              delegate: ListResizeDelegate(stateManager, _columns),
              child: ListView.builder(
                controller: _verticalScroll,
                scrollDirection: Axis.vertical,
                physics: const ClampingScrollPhysics(),
                itemCount: _rows.length,
                itemExtent: stateManager.rowTotalHeight,
                addRepaintBoundaries: false,
                itemBuilder: (ctx, i) {
                  return PlutoBaseRow(
                    key: ValueKey('body_row_${_rows[i].key}'),
                    rowIdx: i,
                    row: _rows[i],
                    columns: _columns,
                    stateManager: stateManager,
                    visibilityLayout: true,
                  );
                },
              ),
            ),
          ),
        ));
  }

  // void _handleTapOutside(BuildContext context, TapDownDetails details,MenuController menuController) {
  //   if (!menuController.isOpen) return; // 没打开就不处理
  //
  //   final RenderBox box = _menuKey.currentContext?.findRenderObject() as RenderBox;
  //   final Offset offset = box.localToGlobal(Offset.zero);
  //   final Size size = box.size;
  //
  //   Rect menuRect = offset & size;
  //
  //   if (!menuRect.contains(details.globalPosition)) {
  //     _menuController.close();
  //   }
  // }
}

class ListResizeDelegate extends SingleChildLayoutDelegate {
  PlutoGridStateManager stateManager;

  List<PlutoColumn> columns;

  ListResizeDelegate(this.stateManager, this.columns)
      : super(relayout: stateManager.resizingChangeNotifier);

  @override
  bool shouldRelayout(covariant SingleChildLayoutDelegate oldDelegate) {
    return true;
  }

  double _getWidth() {
    return columns.fold(
      0,
      (previousValue, element) => previousValue + element.width,
    );
  }

  @override
  Size getSize(BoxConstraints constraints) {
    return constraints.tighten(width: _getWidth()).biggest;
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return const Offset(0, 0);
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return constraints.tighten(width: _getWidth());
  }
}
