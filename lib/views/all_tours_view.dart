import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:visit_braila/controllers/tour_controller.dart';
import 'package:visit_braila/models/tour_model.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/widgets/loading_spinner.dart';
import 'package:visit_braila/widgets/search_list_field.dart';

class AllToursView extends StatefulWidget {
  const AllToursView({super.key});

  @override
  State<AllToursView> createState() => _AllToursViewState();
}

class _AllToursViewState extends State<AllToursView> {
  final TourController tourController = TourController();
  bool isLoading = true;
  List<Tour> tours = [];
  List<Tour> filteredData = [];

  @override
  void initState() {
    super.initState();

    fetchData();
  }

  void fetchData() async {
    tours = await tourController.fetchTours();
    filteredData = tours;
    
    //TODO: what if it has error

    setState(() {
      isLoading = false;
    });
  }

  void updateList(String query) {
    filteredData = [];

    query.trim().toLowerCase().split(" ").forEach((word) {
      filteredData.addAll(
        tours.where(
          (tour) => tour.name.toString().toLowerCase().contains(word) && !filteredData.contains(tour),
        ),
      );
    });

    setState(() {});
  }

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
            style: Theme.of(context).textTheme.headline4!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                ),
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
        child: isLoading
            ? const LoadingSpinner()
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 14,
                  ),
                  child: Column(
                    children: [
                      SearchListField(
                        onChanged: updateList,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      StaggeredGridView.countBuilder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredData.length,
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        itemBuilder: (context, index) {
                          return TourCard(tour: filteredData[index]);
                        },
                        staggeredTileBuilder: (_) => const StaggeredTile.fit(1),
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
    return Hero(
      tag: tour.id,
      child: Material(
        type: MaterialType.transparency,
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, "/tour", arguments: tour),
          child: ClipRRect(
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
          ),
        ),
      ),
    );
  }
}
