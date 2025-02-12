/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:playground_components/playground_components.dart';

import '../../components/builders/content_tree.dart';
import '../../components/expansion_tile_wrapper.dart';
import '../../components/filler_text.dart';
import '../../components/scaffold.dart';
import '../../constants/sizes.dart';
import '../../generated/assets.gen.dart';
import '../../models/abstract_node.dart';
import '../../models/group.dart';
import '../../models/module.dart';
import '../../models/unit.dart';
import 'playground_demo.dart';

class TourScreen extends StatelessWidget {
  const TourScreen();

  @override
  Widget build(BuildContext context) {
    return TobScaffold(
      child: MediaQuery.of(context).size.width > ScreenBreakpoints.twoColumns
          ? const _WideTour()
          : const _NarrowTour(),
    );
  }
}

class _WideTour extends StatelessWidget {
  const _WideTour();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _ContentTree(),
        Expanded(
          child: SplitView(
            direction: Axis.horizontal,
            first: _Content(),
            second: PlaygroundDemoWidget(),
          ),
        ),
      ],
    );
  }
}

class _NarrowTour extends StatelessWidget {
  const _NarrowTour();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _ContentTree(),
              Expanded(child: _Content()),
            ],
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: const _NarrowScreenPlayground(),
          ),
        ],
      ),
    );
  }
}

class _ContentTree extends StatelessWidget {
  const _ContentTree();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.symmetric(horizontal: BeamSizes.size12),
      child: ContentTreeBuilder(
        builder: (context, contentTree, child) {
          if (contentTree == null) {
            return Container();
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const _ContentTreeTitle(),
                ...contentTree.modules
                    .map((module) => _Module(module: module))
                    .toList(growable: false),
                const SizedBox(height: BeamSizes.size12),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Module extends StatelessWidget {
  final ModuleModel module;
  const _Module({required this.module});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ModuleTitle(module: module),
        ...module.nodes
            .map((node) => _Node(node: node))
            .toList(growable: false),
        const BeamDivider(
          margin: EdgeInsets.symmetric(vertical: BeamSizes.size10),
        ),
      ],
    );
  }
}

class _ContentTreeTitle extends StatelessWidget {
  const _ContentTreeTitle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: BeamSizes.size12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'pages.tour.summaryTitle',
            style: Theme.of(context).textTheme.headlineLarge,
          ).tr(),
        ],
      ),
    );
  }
}

class _ModuleTitle extends StatelessWidget {
  final ModuleModel module;
  const _ModuleTitle({required this.module});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BeamSizes.size6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            module.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Padding(
            padding: const EdgeInsets.only(right: BeamSizes.size4),
            child: ComplexityWidget(complexity: module.complexity),
          ),
        ],
      ),
    );
  }
}

class _Node extends StatelessWidget {
  final NodeModel node;
  const _Node({required this.node});

  @override
  Widget build(BuildContext context) {
    if (node is GroupModel) {
      return _Group(group: node as GroupModel);
    } else if (node is UnitModel) {
      return _Unit(unit: node as UnitModel);
    }
    throw Exception('A node with an unknown type');
  }
}

class _Group extends StatelessWidget {
  final GroupModel group;
  const _Group({required this.group});

  @override
  Widget build(BuildContext context) {
    return ExpansionTileWrapper(
      ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: _GroupTitle(title: group.title),
        childrenPadding: const EdgeInsets.only(
          left: BeamSizes.size24,
        ),
        children: [_GroupNodes(nodes: group.nodes)],
      ),
    );
  }
}

class _GroupNodes extends StatelessWidget {
  final List<NodeModel> nodes;
  const _GroupNodes({required this.nodes});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: nodes.map((node) => _Node(node: node)).toList(growable: false),
    );
  }
}

class _Unit extends StatelessWidget {
  final UnitModel unit;
  const _Unit({required this.unit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: BeamSizes.size10),
      child: Row(
        children: [
          _ProgressIndicator(assetPath: Assets.svg.unitProgress0),
          Expanded(child: Text(unit.title)),
        ],
      ),
    );
  }
}

class _GroupTitle extends StatelessWidget {
  final String title;
  const _GroupTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ProgressIndicator(assetPath: Assets.svg.unitProgress0),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  final String assetPath;
  const _ProgressIndicator({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: BeamSizes.size4,
        right: BeamSizes.size8,
      ),
      child: SvgPicture.asset(assetPath),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height -
          BeamSizes.appBarHeight -
          TobSizes.footerHeight,
      decoration: BoxDecoration(
        color: themeData.backgroundColor,
        border: Border(
          left: BorderSide(color: themeData.dividerColor),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: ScrollController(),
              child: const FillerText(width: 1000),
            ),
          ),
          const _ContentFooter(),
        ],
      ),
    );
  }
}

class _ContentFooter extends StatelessWidget {
  const _ContentFooter();

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: themeData.dividerColor),
        ),
        color:
            themeData.extension<BeamThemeExtension>()?.secondaryBackgroundColor,
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(BeamSizes.size20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: themeData.primaryColor,
                side: BorderSide(color: themeData.primaryColor),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(BeamSizes.size4),
                  ),
                ),
              ),
              child: const Text(
                'pages.tour.completeUnit',
                overflow: TextOverflow.ellipsis,
              ).tr(),
              onPressed: () {
                // TODO(nausharipov): complete unit
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NarrowScreenPlayground extends StatelessWidget {
  const _NarrowScreenPlayground();

  @override
  Widget build(BuildContext context) {
    // TODO(alexeyinkin): Even this way the narrow layout breaks, https://github.com/apache/beam/issues/23244
    return const Center(child: Text('TODO: Playground for narrow screen'));
  }
}
