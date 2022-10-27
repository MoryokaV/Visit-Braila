import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:visit_braila/controllers/tour_controller.dart';
import 'package:visit_braila/models/tour_model.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/widgets/loading_spinner.dart';

class AllToursView extends StatelessWidget {
  AllToursView({super.key});

  final TourController tourController = TourController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: kBackgroundColor,
        elevation: 0,
        titleSpacing: 0,
        title: RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: "Explorează ",
              ),
              TextSpan(
                text: "Tururi",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              )
            ],
            style: Theme.of(context).textTheme.headline4!.copyWith(fontWeight: FontWeight.w600, fontSize: 22),
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.adaptive.arrow_back,
            color: kForegroundColor,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 6,
              horizontal: 14,
            ),
            child: Column(
              children: [
                Container(
                  width: Responsive.screenWidth,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: lightGrey,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(
                        CupertinoIcons.search,
                        size: 20,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Caută",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                FutureBuilder<List<Tour>>(
                  future: tourController.fetchTours(),
                  builder: (context, tours) {
                    if (tours.hasData) {
                      return StaggeredGridView.countBuilder(
                        shrinkWrap: true,
                        physics: const ScrollPhysics(),
                        itemCount: tours.data!.length,
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        itemBuilder: (context, index) {
                          return TourCard(tour: tours.data![index]);
                        },
                        staggeredTileBuilder: (_) => const StaggeredTile.fit(1),
                      );
                    }

                    return SizedBox(
                      height: Responsive.safeBlockVertical * 20,
                      child: const LoadingSpinner(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TourCard extends StatelessWidget {
  final Tour tour;

  const TourCard({
    super.key,
    required this.tour,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          Image.network(
            tour.images[tour.primaryImage - 1],
            fit: BoxFit.cover,
          ),
          Positioned.fill(
            child: Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.bottomLeft,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.25),
              ),
              child: Text(
                tour.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
